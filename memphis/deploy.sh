#!/bin/bash

# shellcheck disable=SC2015

PRISMA_API_DEFAULT="https://api.east-01.network.prismacloud.io"

function main() {
  cd "$(dirname "$0")" || return 2

  local fatal=false
  [[ "$NAMESPACE" ]] || { err "Missing required env var NAMESPACE"; fatal=true; }
  [[ "$KUBECONFIG" ]] || { err "Missing required env var KUBECONFIG"; fatal=true; }
  [[ "$PRISMA_CREDS" ]] || { err "Missing required env var PRISMA_CREDS"; fatal=true; }
  $fatal && { err "Fatal"; return 2; }

  [[ "$PRISMA_API" ]] || { PRISMA_API="$PRISMA_API_DEFAULT"; }

  mkdir -p deploy || return 2
  _echoapp "$NAMESPACE" > deploy/kubernetes-app.yaml || return 2
  _echopolicy "$NAMESPACE" > deploy/prisma-policy.yaml || return 2
  cd deploy || return 3
  PATH=$PWD:$PATH
  _install_util || return $?
  _deploy || return $?
  _prismacleanup || return $?
  return 0
}

function _deploy() {
  [[ $DRYRUN ]] && { err "env var DRYRUN is set"; return 0; }
  kubectl --kubeconfig="$KUBECONFIG" apply -f kubernetes-app.yaml || return 3
  apoctl api --creds "$PRISMA_CREDS" -n "$NAMESPACE" import --file prisma-policy.yaml || return 3
}

function _prismacleanup() {
  # This disables discoverymode which is enabled by default (not by us)
  local dm
  dm=$(apoctl api --api "$PRISMA_API" -n "$NAMESPACE" --creds "$PRISMA_CREDS" list discoverymode | jq -r '.[].ID')
  for id in $dm; do
    err "Removing discoverymode policy ${id}"
    apoctl api --api "$PRISMA_API" -n "$NAMESPACE" --creds "$PRISMA_CREDS" delete discoverymode "$id" || return 3
  done
}

function _install_util() {
  local uname
  local type
  uname=$(uname)
  if [[ "$uname" == "Darwin" ]]; then
    type="darwin"
  elif [[ "$uname" == "Linux" ]]; then
    type="linux"
  else
    err "System type ${uname} not supported"
    return 2
  fi

  err "host type is ${type}"

  [ -f apoctl ] && {
    err "apoctl already installed"
  } || {
    err "downloading apoctl"
    curl -o apoctl -L "https://east-01.network.prismacloud.io/repos/apoctl/${type}/apoctl" || return 3
  }
  [ -x apoctl ] || { chmod +x apoctl || return 3; }

  [ -f kubectl ] && {
    err "kubectl already installed"
  } || {
    err "downloading kubectl"
    local ver
    ver=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
    curl -o kubectl -L "https://storage.googleapis.com/kubernetes-release/release/${ver}/bin/${type}/amd64/kubectl" || return 3
  }
  [ -x kubectl ] || { chmod +x kubectl || return 3; }

  [ -f jq ] && {
    err "jq already installed"
  } || {
    err "downloading jq"
    local url
    url="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
    [[ "$type" == "darwin" ]] && {
      url="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64"
    }
    curl -o jq -L "$url" || return 3
  }
  [ -x jq ] || { chmod +x jq || return 3; }

  return 0
}

function _echoapp() {
  local ns
  ns=$(basename "$1")
  sed "s/{{ .Kubernetes.Namespace }}/$ns/g" kubernetes-app.input
  echo "---"
  kubectl create configmap -n temp_namespace run --dry-run=client -o yaml --from-file=backend.sh,middleware.sh,frontend.sh | sed "s/temp_namespace/$ns/g" || {
    err "Failed to create scripts"
  }
  return 0
}

function _echopolicy() {
  local ns
  local app
  ns=$(echo "$1" | sed 's/\//\\\//g')
  app=$(basename "$1")
  sed "s/{{ .Prisma.Namespace }}/$ns/g" prisma-policy.input | sed "s/{{ .Prisma.Label }}/$app/g"
}

function err() { echo "$@" 1>&2; }

main "$@"
