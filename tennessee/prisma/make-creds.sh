#!/bin/bash

function main() {

  cd "$(dirname "$0")" || return 2
  [ -f settings ] && . settings
  token=$1
  [[ "$token" ]] || { err "Usage:$0 token"; return 2; }

  local rc
  rc=0
  [ "$TENANT" ] || { err "Missing env var TENANT"; rc=2; }
  [ "$CLOUD" ] || { err "Missing env var CLOUD"; rc=2; }
  [ "$GROUP" ] || { err "Missing env var GROUP"; rc=2; }
  [ "$rc" -eq 0 ] || return 3

  apoctl --token "$token" appcred create cicdcreds -n /${TENANT}/${CLOUD}/${GROUP} --role @auth:role=namespace.administrator > $APOCTL_CREDS
  rc=$?
  [ "$rc" -eq 0 ] || { err "Failed"; return $rc; }
}

function err() { echo "$@" 1>&2; }

main "$@"
