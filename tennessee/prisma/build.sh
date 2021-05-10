#!/bin/bash

KUBEDNS_DEFAULT=10.100.0.10

function main() {
  cd "$(dirname "$0")" || return 2
  [ -f settings ] && . settings

  [ -f appcreds.json ] && { APOCTL_PREPEND="--creds appcreds.json"; }

  local rc
  rc=0
  [ "$CLOUD" ] || { err "Missing env var CLOUD"; rc=2; }
  [ "$GROUP" ] || { err "Missing env var GROUP"; rc=2; }
  [ "$TENANT" ] || { err "Missing env var TENANT"; rc=2; }
  [ "$rc" -eq 0 ] || return 3

  [[ "$KUBEDNS" ]] && {
    process kubedns-rule.yaml
    process kubedns-net.yaml
  }

  process secops-rule.yaml
  process nashville-rule.yaml
  process memphis-rule.yaml
  process knoxville-rule.yaml

  create_ns > create-ns.sh
  create_policy > create-policy.sh

	chmod +x create-ns.sh create-policy.sh
}

function create_ns()
{
cat <<EOF
#!/bin/bash -xe

apoctl api ${APOCTL_PREPEND} create namespace -n /${TENANT}/${CLOUD}/${GROUP} --data '{"name": "nashville"}'
apoctl api ${APOCTL_PREPEND} create namespace -n /${TENANT}/${CLOUD}/${GROUP} --data '{"name": "memphis"}'
apoctl api ${APOCTL_PREPEND} create namespace -n /${TENANT}/${CLOUD}/${GROUP} --data '{"name": "knoxville"}'
EOF
}

function create_policy()
{
cat <<EOF
#!/bin/sh -xe
EOF
[[ "$KUBEDNS" ]] && {
cat <<EOF
apoctl api ${APOCTL_PREPEND} -n /${TENANT}/${CLOUD}/${GROUP} import --file kubedns-net.yaml
apoctl api ${APOCTL_PREPEND} -n /${TENANT}/${CLOUD}/${GROUP} import --file kubedns-rule.yaml
EOF
}
cat <<EOF
apoctl api ${APOCTL_PREPEND} -n /${TENANT}/${CLOUD}/${GROUP} import --file secops-rule.yaml
apoctl api ${APOCTL_PREPEND} -n /${TENANT}/${CLOUD}/${GROUP}/nashville import --file nashville-rule.yaml
apoctl api ${APOCTL_PREPEND} -n /${TENANT}/${CLOUD}/${GROUP}/memphis import --file memphis-rule.yaml
apoctl api ${APOCTL_PREPEND} -n /${TENANT}/${CLOUD}/${GROUP}/knoxville import --file knoxville-rule.yaml
EOF
}

function process() {
  sed "s/{{.Values.org.cloudAccount}}/${CLOUD}/g" < "src/$1" |
  sed "s/{{.Values.org.group}}/${GROUP}/g" |
  sed "s/{{.Values.org.tenant}}/${TENANT}/g" |
  sed "s/{{.Values.kubeDns}}/${KUBEDNS}/g" > "$1"
}

function echo_settings()
{
cat <<EOF
export TENANT=$tenant
export CLOUD=$cloud
export GROUP=$group
export KUBEDNS=$KUBEDNS
export APOCTL_API=$APOCTL_API
export APOCTL_TOKEN=$APOCTL_TOKEN
EOF
}

main "$@"
