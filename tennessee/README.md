# tennessee

## Overview
This is a simple Kubernetes application that simulates network connectivity between three
namespaces running on the same cluster. 

The three namespaces are named Nashville, Memphis and
Knoxville. The Nashville namespace runs a single pod called database. Memphis and Knoxville
each run a frontend and backend pod. Memphis and Knoxville our sibling applications that
depend on Knoxville.

## Operation

### Nashville
Nashville is the capital of Tennessee. It runs 

Memphis has a pod called frontend and a pod called backend. The frontend simulates a web 
frontend. It connects to the backend. 

Memphis and Knoxville each have a pod called frontend that connects to backend 

The Frontned podset terminates inbound http(s) connections and is generally stateless.
All client request must be forwarded to the Middleware podset. The Middlware represents the
business logic. The Middlware holds state and must form a cluster with the other Middlware podsets.
Finally the Backend podset represents the Database layer.

### Rules
1. Frontend podset may accept inbound from anywhere
1. Middleware podset may accept inbound from Frontend podset and make connections to Middlware
podset and Backend podset
1. Backend podset may accept inbound from Middlware podset and make connections to Backend podset
1. All pods may communicate with infrasturucutre such as DNS
1. Anything not explicity permitted should be denied. For example Frontend to Frontend podset
communication is not explicity permitted hence it should be denied.

### Scripts
Each script starts a webserver and then runs an infinite event loop. The event loop will call and
event every 2 seconds. The event is customized per podset type (frontend, middleware, backend).

## Usage

### Overview
Clone the repo to disk and set the env vars NAMESPACE, KUBECONFIG, and PRISMA_CREDS. Then run the
script deploy.sh

### Example
```bash
export NAMESPACE=/panwdevapp2/jody/flyingcloud/memphis
export KUBECONFIG=/my/kube.config
export PRISMA_CREDS=/my/prismacreds.json
git clone https://github.com/aporeto-se/k8s-simple-apps.git app
./app/memphis/deploy.sh
```

### Jenkins
A Jenkins pipeline script is also provided. It performs the same actions as the example.
