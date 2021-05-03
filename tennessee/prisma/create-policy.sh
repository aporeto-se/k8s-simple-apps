#!/bin/sh -xe
apoctl api -n /806775361903163392/jody/k1-us-east-2-eksctl-io import --file config.yaml
apoctl api -n /806775361903163392/jody/k1-us-east-2-eksctl-io/nashville import --file nashville.yaml
apoctl api -n /806775361903163392/jody/k1-us-east-2-eksctl-io/memphis import --file memphis.yaml
apoctl api -n /806775361903163392/jody/k1-us-east-2-eksctl-io/knoxville import --file knoxville.yaml
