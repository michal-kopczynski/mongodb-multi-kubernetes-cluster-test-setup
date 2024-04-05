#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/env.sh

printf "\n"
echo ">>> Switch context to central cluster"
kubectl config use-context "${MDB_CENTRAL_CLUSTER_FULL_NAME}"

printf "\n"
echo ">>> Deploy MongoDBMultiCluster replica in namespace $MDB_PROJECT"
# Specification: https://www.mongodb.com/docs/kubernetes-operator/stable/reference/k8s-operator-multi-cluster-specification/
kubectl apply -f - <<EOF
apiVersion: mongodb.com/v1
kind: MongoDBMultiCluster
metadata:
 name: multi-replica-set
 namespace: ${MDB_PROJECT}
spec:
 version: "${MDB_APPDB_VERSION}"
 type: ReplicaSet
 persistent: false
 duplicateServiceObjects: true
 credentials: organization-secret
 opsManager:
   configMapRef:
     name: ${MDB_PROJECT}
 clusterSpecList:
   - clusterName: ${MDB_CLUSTER_1_FULL_NAME}
     members: 1
   - clusterName: ${MDB_CLUSTER_2_FULL_NAME}
     members: 2
EOF

# echo ">>> Troubleshooting:
# - Replica set Failed because of:
#    'Error establishing connection to Ops Manager: failed to generate agent'
#    'Status: 403 (Forbidden), ErrorCode: RESOURCE_REQUIRES_ACCESS_LIST'
#    'This resource requires access through an access list of ip ranges.'
#   even though 'Require IP Access List for the Ops Manager Administration API' is disabled in org settings.
#   Solution:
#    * Go to ops-manager-db organization
#    * Organization -> Access Manager -> API Keys -> Actions -> Edit Permissions
#    * Add to API Access List cluster IP or i.e. 0.0.0.0/1
# - Replica set Failed because of:
#     'Not all the Pods are ready'
#     or
#     'Automation agents haven't reached READY state during defined interval'
#   Solution: Check cross-cluster connectivity (i.e. use Istio), also multi-replica-set pods require usually 2-4 minutes to reach READY state.
# - After deletion of MongoDBMultiCluster some replicas are not terminated on member clusters:
#     with errors in logs: 'RSM received error response'/'Host failed in replica set'
#   Workaround: kubectl --context CLUSTER -n mongodb delete pod multi-replica-set-1-0-2 --grace-period=0 --force"
