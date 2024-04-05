#!/bin/bash

export MDB_GKE_PROJECT=***PROJECT***

export MDB_CENTRAL_CLUSTER=***CLUSTER_NAME***
export MDB_CENTRAL_CLUSTER_ZONE="us-central1-c"
export MDB_CENTRAL_CLUSTER_FULL_NAME="gke_${MDB_GKE_PROJECT}_${MDB_CENTRAL_CLUSTER_ZONE}_${MDB_CENTRAL_CLUSTER}"

export MDB_CLUSTER_1=***CLUSTER_NAME***
export MDB_CLUSTER_1_ZONE="us-central1-c"
export MDB_CLUSTER_1_FULL_NAME="gke_${MDB_GKE_PROJECT}_${MDB_CLUSTER_1_ZONE}_${MDB_CLUSTER_1}"

export MDB_CLUSTER_2=***CLUSTER_NAME***
export MDB_CLUSTER_2_ZONE="us-central1-c"
export MDB_CLUSTER_2_FULL_NAME="gke_${MDB_GKE_PROJECT}_${MDB_CLUSTER_2_ZONE}_${MDB_CLUSTER_2}"

# Namespace for OpsManager
export MDB_NS="mongodb"
# Namespace for operator and replicas / MongoDB project name
export MDB_PROJECT="mongodb-1"

export MDB_OM_VERSION=5.0.18
export MDB_APPDB_VERSION=5.0.18-ent

export MDB_OM_USERNAME=opsmanager@example.com
export MDB_OM_PASSWORD=p@ssword123

# Create .env file after executing 1-setup-ops-manager.sh
source .env

echo ">>> Using environment variables:"
echo MDB_CENTRAL_CLUSTER_FULL_NAME: $MDB_CENTRAL_CLUSTER_FULL_NAME
echo MDB_CLUSTER_1_FULL_NAME: $MDB_CLUSTER_1_FULL_NAME
echo MDB_CLUSTER_2_FULL_NAME: $MDB_CLUSTER_2_FULL_NAME
echo MDB_NS: $MDB_NS
echo REPLICA_PROJECT: $MDB_PROJECT
