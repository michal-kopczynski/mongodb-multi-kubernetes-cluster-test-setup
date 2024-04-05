#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/env.sh

printf "\n"
echo ">>> Switch context to central cluster"
kubectl config use-context "${MDB_CENTRAL_CLUSTER_FULL_NAME}"

printf "\n"
echo ">>> Create secret for the organisation"
# https://www.mongodb.com/docs/kubernetes-operator/master/tutorial/create-operator-credentials/#std-label-create-k8s-credentials
# https://www.mongodb.com/docs/kubernetes-operator/master/tutorial/create-project-using-configmap/#std-label-create-k8s-project
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: organization-secret
  namespace: ${MDB_PROJECT}
stringData:
  user: ${MDB_ORG_USER}
  publicApiKey: ${MDB_ORG_API_KEY}
EOF

printf "\n"
echo ">>> Create ConfigMap"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${MDB_PROJECT}
  namespace: ${MDB_PROJECT}
data:
  projectName: ${MDB_PROJECT}
  orgId: ${MDB_ORG_ID}
  baseUrl: ${MDB_ORG_BASE_URL}
EOF
