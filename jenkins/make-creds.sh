#!/bin/bash -e

# set -x

USERNAME="jenkins"
NAMESPACE="jenkins"

function main() {
  local tmp
  tmp="$(mktemp -d)"
  function cleanup() { rm -rf "$tmp"; }
  trap cleanup EXIT

  [ -d creds ] || {
    err "Creating certificate"
    local tmpcreds
    tmpcreds="$(mktemp -d)"
    pushd "$tmpcreds"
    openssl genrsa -out key 4096
    echo_config > "${tmp}/config"
    openssl req -new -key key -out csr -config "${tmp}/config"
    popd > /dev/null 2>&1
    mv "$tmpcreds" creds
  }

  pushd creds > /dev/null 2>&1

  local json
  json=$(kubectl config view --flatten --minify -o json)
  [[ "$json" ]] || { return 3; }

  local server
  server="$(echo "$json" | jq -r '.clusters[].cluster.server')"

  echo "$json" | jq -r '.clusters[].cluster."certificate-authority-data"' |
    base64 --decode > "${tmp}/ca"

  [ -f crt ] || {
    err "Sending certificate signing request"
    [ -f csr ] || { err "File csr not found; invalid state"; return 3; }
    echo_csr "$(base64 csr | tr -d '\n')" > csr.yaml
    kubectl create -f csr.yaml
    kubectl certificate approve "$USERNAME"
    kubectl get csr "$USERNAME" -o jsonpath='{.status.certificate}' | base64 --decode > crt
    rm -rf csr csr.yaml
    kubectl delete csr "$USERNAME"

    kubectl --kubeconfig=kube.config config set-cluster k8s --embed-certs=true --server="$server" \
      --certificate-authority="${tmp}/ca"

    kubectl --kubeconfig=kube.config config set-credentials "$USERNAME" \
      --embed-certs=true \
      --username=system:serviceaccount:"${NAMESPACE}:${USERNAME}" \
      --client-key=key \
      --client-certificate=crt

    kubectl --kubeconfig=kube.config config set-context k8s --cluster=k8s --user="$USERNAME"
    kubectl --kubeconfig=kube.config config use-context k8s
  }

}

echo_csr() 
{
cat << EOF
kind: CertificateSigningRequest
apiVersion: certificates.k8s.io/v1beta1
metadata:
  name: jenkins
spec:
  groups:
  - system:authenticated
  request: "$1"
  usages:
  - client auth
  - server auth
  - digital signature
  - key encipherment
EOF
}

echo_config()
{
cat << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = US
ST = TX
L = Southlake
O = OPS
OU = OPS
CN = system:serviceaccount:${NAMESPACE}:${USERNAME}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = kubernetes

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF
}

function err() { echo "$@" 1>&2; }

main "$@"
