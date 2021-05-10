#!/bin/bash

# export APOCTL_API=https://api.east-01.network.prismacloud.io
# export APOCTL_TOKEN=



apoctl api create apiauthorizationpolicy \
--namespace /806775361903163392/jody/k1-us-east-2-eksctl-io \
--api  \
--data '{
  "authorizedNamespace": "/806775361903163392/jody/k1-us-east-2-eksctl-io",
  "allowsGet": false,
  "allowsPost": false,
  "allowsPut": false,
  "allowsDelete": false,
  "allowsPatch": false,
  "allowsHead": true,
  "authorizedIdentities": [
    "@auth:role=namespace.administrator"
  ],
  "subject": [
    [
      "@auth:realm=pcidentitytoken"
    ]
  ],
  "name": "appcreds"
}'
