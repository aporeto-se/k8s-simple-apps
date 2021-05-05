#!/bin/sh -xe
apoctl api -n /806775361903163392/jody/k1-us-east-2-eksctl-io import --file kubedns-net.yaml
apoctl api -n /806775361903163392/jody/k1-us-east-2-eksctl-io import --file kubedns-rule.yaml
apoctl api -n /806775361903163392/jody/k1-us-east-2-eksctl-io import --file secops-rule.yaml
apoctl api -n /806775361903163392/jody/k1-us-east-2-eksctl-io/nashville import --file nashville-rule.yaml
apoctl api -n /806775361903163392/jody/k1-us-east-2-eksctl-io/memphis import --file memphis-rule.yaml
apoctl api -n /806775361903163392/jody/k1-us-east-2-eksctl-io/knoxville import --file knoxville-rule.yaml
