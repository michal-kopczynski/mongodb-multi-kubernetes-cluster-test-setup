#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/env.sh

printf "\n"
echo ">>> Create GKE clusters"
gcloud container clusters create $MDB_CENTRAL_CLUSTER \
  --project=$MDB_GKE_PROJECT \
  --zone=$MDB_CENTRAL_CLUSTER_ZONE \
  --num-nodes=6 \
  --machine-type "e2-standard-2"

gcloud container clusters create $MDB_CLUSTER_1 \
  --project=$MDB_GKE_PROJECT \
  --zone=$MDB_CLUSTER_1_ZONE \
  --num-nodes=6 \
  --machine-type "e2-standard-2"

gcloud container clusters create $MDB_CLUSTER_2 \
  --project=$MDB_GKE_PROJECT \
  --zone=$MDB_CLUSTER_2_ZONE \
  --num-nodes=6 \
  --machine-type "e2-standard-2"

printf "\n"
echo ">>> Obtain user authentication credentials for created clusters"
gcloud container clusters get-credentials $MDB_CENTRAL_CLUSTER \
  --project=$MDB_GKE_PROJECT \
  --zone=$MDB_CENTRAL_CLUSTER_ZONE
gcloud container clusters get-credentials $MDB_CLUSTER_1 \
  --project=$MDB_GKE_PROJECT \
  --zone=$MDB_CLUSTER_1_ZONE
gcloud container clusters get-credentials $MDB_CLUSTER_2 \
  --project=$MDB_GKE_PROJECT \
  --zone=$MDB_CLUSTER_2_ZONE

printf "\n"
echo ">>> Switch context to central cluster"
kubectl config use-context "${MDB_CENTRAL_CLUSTER_FULL_NAME}"
