#!/bin/bash

kubectl apply -f nashville/ns.yaml
kubectl apply -f memphis/ns.yaml
kubectl apply -f knoxville/ns.yaml

sleep 2

kubectl apply -f nashville
kubectl apply -f memphis
kubectl apply -f knoxville
