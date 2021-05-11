#!/bin/bash
# shellcheck disable=SC2015

function main() {

  cd "$(dirname "$0")" || return 2

  local api
  local ns
  local token
  local tenant
  local cloud
  local group

  api=$(echo "$@" | awk '{print $4}')
  ns=$(echo "$@" | awk '{print $6}')
  token=$(echo "$@" | awk '{print $8}')
  tenant=$(echo "$ns" | awk -F/ '{print $2}')
  cloud=$(echo "$ns" | awk -F/ '{print $3}')
  group=$(echo "$ns" | awk -F/ '{print $4}')

  [[ "$api" ]] || { err "Invalid input"; return 3; }
  [[ "$ns" ]] || { err "Invalid input"; return 3; }
  [[ "$tenant" ]] || { err "Invalid input; mising tenant"; return 3; }
  [[ "$cloud" ]] || { err "Invalid input; missing cloud"; return 3; }
  [[ "$group" ]] || { err "Invalid input; missing group"; return 3; }

cat <<EOF > settings
# Get this information from the Prisma Console
export TENANT=$tenant
export CLOUD=$cloud
export GROUP=$group
export APOCTL_API=$api

export APOCTL_CREDS=appcreds.json

# If KUBEDNS is not set then we will automatically resolve it
# export KUBEDNS=

# Probably dont change this
export APOCTL_NAMESPACE="/\${TENANT}/\${CLOUD}/\${GROUP}"
EOF

  [[ "$token" ]] && {
    err "Token present, making creds"
    ./make-creds.sh "$token"
  } || {
    err "Token not present"
  }

}

function err() { echo "$@" 1>&2; }

main "$@"
