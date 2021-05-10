#!/bin/bash
# This script converts the apoctl command from the Prisma UI into the settings

function main() {
  local ns
  local tenant
  local cloud
  local group
  local kubedns

  APOCTL_API=${4}
  ns=${6}
  APOCTL_TOKEN=${8}
  tenant=$(echo "$ns" | awk -F/ '{print $2}')
  cloud=$(echo "$ns" | awk -F/ '{print $3}')
  group=$(echo "$ns" | awk -F/ '{print $4}')

  [ -f settings ] && { . settings; }

  [[ "$tenant" ]] && { TENANT=${tenant}; }
  [[ "$cloud" ]] && { CLOUD=${cloud}; }
  [[ "$group" ]] && { GROUP=${group}; }

  kubedns=$(kubectl get services -n kube-system kube-dns -o=jsonpath="{.spec.clusterIP}")

  [[ "$kubedns" ]] || { KUBEDNS=${kubedns}; }
  echo_settings > settings
}

function echo_settings()
{
cat <<EOF
export TENANT=$TENANT
export CLOUD=$CLOUD
export GROUP=$GROUP
export KUBEDNS=$KUBEDNS
export APOCTL_API=$APOCTL_API
export APOCTL_NAMESPACE="\${TENANT}/\${CLOUD}/\${GROUP}"

# Token is time bound
export APOCTL_TOKEN=$APOCTL_TOKEN
EOF
}

main "$@"
