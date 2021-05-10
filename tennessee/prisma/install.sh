#!/bin/bash
# shellcheck disable=SC2015

function main() {
  _main || { err "Fail"; return 3; }
  return 0
}

function _main() {
  cd "$(dirname "$0")" || return 2
  [ -f settings ] && . settings

  trap "rm -rf tmp" EXIT

  local rc
  rc=0
  [ "$CLOUD" ] || { err "Missing env var CLOUD"; rc=2; }
  [ "$GROUP" ] || { err "Missing env var GROUP"; rc=2; }
  [ "$TENANT" ] || { err "Missing env var TENANT"; rc=2; }
  [ "$rc" -eq 0 ] || return 3

  [[ "$KUBEDNS" ]] && {
    err "Using KUBEDNS from settings"
  } || {
    err "Getting kubedns from Kubernetes"
    KUBEDNS=$(kubectl get services -n kube-system kube-dns -o=jsonpath="{.spec.clusterIP}")
  }
  [[ "$KUBEDNS" ]] || { err "Unable to resolve KUBEDNS, please set in settings"; return 3; }

  err "KUBEDNS is $KUBEDNS"

  err "Creating namespaces if they do not exist"
  make_ns nashville memphis knoxville || return 3

  rm -rf tmp && mkdir tmp

  err "Generating yaml"
  process kubedns-rule.yaml kubedns-net.yaml secops-rule.yaml nashville-rule.yaml memphis-rule.yaml knoxville-rule.yaml || return 3

  err "Installing configuration"
  apoctl api import -n /${TENANT}/${CLOUD}/${GROUP} --file tmp/kubedns-net.yaml || return 3
  apoctl api import -n /${TENANT}/${CLOUD}/${GROUP} --file tmp/kubedns-rule.yaml || return 3
  apoctl api import -n /${TENANT}/${CLOUD}/${GROUP} --file tmp/secops-rule.yaml || return 3
  apoctl api import -n /${TENANT}/${CLOUD}/${GROUP}/nashville --file tmp/nashville-rule.yaml || return 3
  apoctl api import -n /${TENANT}/${CLOUD}/${GROUP}/memphis --file tmp/memphis-rule.yaml || return 3
  apoctl api import -n /${TENANT}/${CLOUD}/${GROUP}/knoxville --file tmp/knoxville-rule.yaml || return 3
}

function process() {
  for x in "$@"; do
    _process "$x"
  done
}

function _process() {
  sed "s/{{.Values.org.cloudAccount}}/${CLOUD}/g" < "src/$1" |
  sed "s/{{.Values.org.group}}/${GROUP}/g" |
  sed "s/{{.Values.org.tenant}}/${TENANT}/g" |
  sed "s/{{.Values.kubeDns}}/${KUBEDNS}/g" > "tmp/$1"
}

function make_ns() {
  for x in "$@"; do
    _make_ns "$x"
  done
}

function _make_ns() {
  ns=$1
  exist=$(apoctl api list namespaces -f "name == $APOCTL_NAMESPACE/$ns" | sed 's/\[//g' | sed 's/\]//g')
  [[ "$exist" ]] && { err "Namespace $ns exist"; return 0; }
  err "Creating namespace $ns"
  apoctl api create namespace -n "$APOCTL_NAMESPACE" --data "{\"name\": \"$ns\"}" || return 3
  return 0
}

function err() { echo "$@" 1>&2; }

main "$@"
