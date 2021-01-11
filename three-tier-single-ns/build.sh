#!/bin/bash

set -e

main() {
  cd "$(dirname "$0")" || return 2
  local ns

  ns="$1"

  [[ "$1" ]] || { ns="$NAMESPACE"; }
  [[ "$ns" ]] || { err "Provide namespace as first arg or set env var NAMESPACE"; return 2; }

  mkdir -p build
  cd build
  echoapp "$ns" > kubernetes-app.yaml || return 3
  echopolicy "$ns" > prisma-policy.yaml || return 3
  err "Completed"
}

function echoapp() {
  local ns
  ns=$(basename "$1")
  sed "s/{{ .Kubernetes.Namespace }}/$ns/g" kubernetes-app.input
  echo "---"
  kubectl create configmap -n temp_namespace run --dry-run=client -o yaml --from-file=backend.sh,middleware.sh,frontend.sh | sed "s/temp_namespace/$ns/g" || {
    err "Failed to create scripts"
  }
  return 0
}

function echopolicy() {
  local ns
  local app
  ns=$(echo "$1" | sed 's/\//\\\//g')
  app=$(basename "$1")
  sed "s/{{ .Prisma.Namespace }}/$ns/g" prisma-policy.input | sed "s/{{ .Prisma.Label }}/$app/g"
}

function err() { echo "$@" 1>&2; }

main "$@"
