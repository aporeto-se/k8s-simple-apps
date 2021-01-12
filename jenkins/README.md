# jenkins

## Overview
This is a simple Jenkins deployment for Kubernetes in an AWS environment. The service and storage
definitions assume AWS and would need to be modified for other deployments. It deploys a single
instance of Jenkins and exposes it via an AWS NLB service. Also included is a definittion to create
a Service Account, Cluster Role and Cluster Role Binding and a script to create credentials for
the service account.

## Script(s)
The script 'make-creds.sh' creates a private key, certificate and Kubernetes config file for the
user 'jenkins'. When executed a directory 'creds' will be created that contains the aformentioned
entities.

## Example
```bash
kubectl create -f deployment.yaml
kubectl create -f service-account.yaml
./make-creds.sh
```