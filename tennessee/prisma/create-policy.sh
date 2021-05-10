#!/bin/sh -xe
apoctl api  -n /806775361903163392/jody/ek2 import --file kubedns-net.yaml
apoctl api  -n /806775361903163392/jody/ek2 import --file kubedns-rule.yaml
apoctl api  -n /806775361903163392/jody/ek2 import --file secops-rule.yaml
apoctl api  -n /806775361903163392/jody/ek2/nashville import --file nashville-rule.yaml
apoctl api  -n /806775361903163392/jody/ek2/memphis import --file memphis-rule.yaml
apoctl api  -n /806775361903163392/jody/ek2/knoxville import --file knoxville-rule.yaml
