# mongodb-multi-kubernetes-cluster-test-setup
Step by step instructions and scripts for creating multi-kubernetes-cluster MongoDB replicas for testing purposes.

Based on https://www.mongodb.com/docs/kubernetes-operator/master/multi-cluster-quick-start/

## Prerequisites
* gcloud CLI
* Helm
* Mongodb kubectl plugin https://www.mongodb.com/docs/kubernetes-operator/master/multi-cluster-prerequisites/#install-the-kubectl-mongodb-plugin

## Setup infrastructure
1. Configure GKE project name, cluster names, namespaces, versions etc. in `env.sh`
2. Deploy GKE clusters
   `./0-setup-infra.sh`
3. Deploy MongoDB OpsManager
   `./1-setup-ops-manager.sh`

## Create MongoDB multi-cluster replicas
1. Create operator
   `./2-setup-operator.sh`
   (for now using seperate operator for each replica)
1. Create secret and config
   `/3-setup-replica-config.sh`
1. Deploy replicas
    `./4-deploy-replica.sh`

## Not covered
* Setting up cross-cluster communication for MongoDB replicas (for example use Istio).