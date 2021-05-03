# tennessee

## Overview
This is a simple Kubernetes application that simulates network connectivity between three namespaces running on the same cluster. The namespaces are named Nashville, Memphis and Knoxville. Memphis and Knoxville are sibling cities. Nashville is the state capital. The sibling cities have a dependency on the capital.

## Simulated Cloud, Region & Account
The tags 'sim-cloud', 'sim-region' and 'sim-account' are used for simulation purposes. This allows us to simulate multiple clouds, regions and accounts within our single cluster. To accomplish this each deployment.yaml is composed of multiple deployments with these aforementioned tags. For example a podset named frontend will actually be named frontend1, frontend2, frontend...N.

## Network Flows

### City (Memphis & Knoxville)
A city is composed of a frontend and a backend. The frontend communicates with the backend and the backend communicates with the database running in Nashville. No other flows should be permitted. For clarification the frontend for a given city should only communicate with the backed located in the same city. Frontends should not communicate with each other. Backends should not originate connections to anywhere except the database in Nashville.

### Capital (Nashville)
Nashville simulates a database cluster. It has a single deployment called database. Database podsets communicate with other database podsets and accept inbound from city backends.

## Policy

### Infrastructure
A policy is included that will permit any workload running on the cluster to access the cluster DNS (Kube DNS). This demonstrates how infrastructure policies need only be created once and then inherited by new applications.

### SecOPS / Org
A policy is included that will restrict flows from sim-account=10 to sim-account=30. This demonstrates how the SecOPS team can create policy that is inherited by children and can not be overridden.

### Application
Policy configuration for each namespace is provided. The configuration for Memphis and Knoxville is virtually identical.

## Rouge Traffic
Rogue traffic can be generated in Memphis by running rogue-frontend or rogue-backend in the directory k8s

## Deployment

### Steps
1. Clone this repo
2. Change into the directory tennessee/prisma
3. Set the variables CLOUD, GROUP and TENANT in the file Makefile
4. Run make
5. If the namespaces do not already exist in prisma create them with ./create-ns.sh
6. Install the policy with ./create-policy.sh
7. Change into the directory tennessee/k8s
8. Deploy with the command ./deploys.sh

### Example
```bash
git pull https://github.com/aporeto-se/k8s-simple-apps.git
cd k8s-simple-apps/tennessee/prisma
make
./create-ns.sh
./create-policy.sh
cd ../k8s
./deploy.sh

# Verify flows
./rogue-frontend
./rouge-backend
```




