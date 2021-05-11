#!/bin/bash
# shellcheck disable=SC2064

# KUBEDNS=

function main() {
  _main || { err "Fail"; return 3; }
  return 0
}

function _main() {
  cd "$(dirname "$0")" || return 2

  # Comment out this line to preserve config
  tmp=$PWD/tmp
  trap "rm -rf $tmp" EXIT
  rm -rf "$tmp" && mkdir -p "$tmp"
  cd "$tmp" || return 2

  err "Generating configuration"

  [[ "$KUBEDNS" ]] || {
    KUBEDNS=$(kubectl get services -n kube-system kube-dns -o=jsonpath="{.spec.clusterIP}")
  }
  [[ "$KUBEDNS" ]] || { err "Unable to resolve KUBEDNS, please set in settings"; return 3; }

  _process kubedns-rule.yaml kubedns-net.yaml secops-rule.yaml nashville-rule.yaml memphis-rule.yaml knoxville-rule.yaml || return 3
  _run || return 3
  ./run.sh || return $?
}

function _run()
{

local input
input=${HOME}/.apoctl/default.yaml
[ -f "$input" ] || { err "File $input does not exist; did you configure apoctl?"; return 3; }

cat <<EOF > run.sh
#!/bin/bash -e
EOF

sed 's/api: /export APOCTL_API=/g' < "$input" |
sed 's/creds: /export APOCTL_CREDS=/g' |
sed 's/namespace: /export APOCTL_NAMESPACE=/g' >> run.sh

cat <<EOF >> run.sh

function main() {
  _main || { err "Failed!"; return 3; }
}

function _main() {
  cd "\$(dirname "\$0")" || return 2
  apoctl api import -n \$APOCTL_NAMESPACE --file kubedns-net.yaml || return \$?
  apoctl api import -n \$APOCTL_NAMESPACE --file kubedns-rule.yaml || return \$?
  apoctl api import -n \$APOCTL_NAMESPACE --file secops-rule.yaml || return \$?
  apoctl api import -n \$APOCTL_NAMESPACE/nashville --file nashville-rule.yaml || return \$?
  apoctl api import -n \$APOCTL_NAMESPACE/memphis --file memphis-rule.yaml || return \$?
  apoctl api import -n \$APOCTL_NAMESPACE/knoxville --file knoxville-rule.yaml || return \$?
}

function err() { echo "\$@" 1>&2; }

main "\$@"
EOF
chmod +x run.sh
}

function _process() {
  for x in "$@"; do
    _sub_process "$x"
  done
}

function _sub_process() {
  sed "s/{{.Values.org.cloudAccount}}/${CLOUD}/g" < "../src/$1" |
  sed "s/{{.Values.org.group}}/${GROUP}/g" |
  sed "s/{{.Values.org.tenant}}/${TENANT}/g" |
  sed "s/{{.Values.kubeDns}}/${KUBEDNS}/g" > "$1"
}

function err() { echo "$@" 1>&2; }

main "$@"
