#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/env.sh

printf "\n"
echo ">>> Switch context to central cluster"
kubectl config use-context "${MDB_CENTRAL_CLUSTER_FULL_NAME}"

printf "\n"
echo ">>> Prepare the cluster for MongoDB multi-cluster but doesn't yet deploy it"
kubectl mongodb multicluster setup \
  --central-cluster="${MDB_CENTRAL_CLUSTER_FULL_NAME}" \
  --member-clusters="${MDB_CLUSTER_1_FULL_NAME},${MDB_CLUSTER_2_FULL_NAME}" \
  --member-cluster-namespace=${MDB_PROJECT} \
  --central-cluster-namespace=${MDB_PROJECT} \
  --create-service-account-secrets \
  --install-database-roles=true

printf "\n"
echo ">>> Add the MongoDB Helm Charts for Kubernetes repository to Helm."
helm repo add mongodb https://mongodb.github.io/helm-charts

printf "\n"
echo ">>> Install operator"
helm upgrade \
  --install \
    mongodb-enterprise-operator-multi-cluster \
    mongodb/enterprise-operator \
      --namespace $MDB_PROJECT \
      --set namespace=$MDB_PROJECT \
      --set operator.name=mongodb-enterprise-operator-multi-cluster \
      --set operator.createOperatorServiceAccount=false \
      --set "multiCluster.clusters={$MDB_CLUSTER_1_FULL_NAME,$MDB_CLUSTER_2_FULL_NAME}" \
      --set multiCluster.performFailover=false
