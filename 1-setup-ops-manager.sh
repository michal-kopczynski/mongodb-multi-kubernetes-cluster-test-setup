#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/env.sh

# https://www.mongodb.com/developer/products/connectors/mastering-ops-manager/
# https://www.mongodb.com/docs/kubernetes-operator/master/om-resources/

printf "\n"
echo ">>> Switch context to central cluster."
kubectl config use-context "${MDB_CENTRAL_CLUSTER_FULL_NAME}"

printf "\n"
echo ">>> create namespace $MDB_NS."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $MDB_NS
EOF

printf "\n"
echo ">>> Prepare the cluster for MongoDB multi-cluster but doesn't yet deploy it."
kubectl mongodb multicluster setup \
  --central-cluster="${MDB_CENTRAL_CLUSTER_FULL_NAME}" \
  --member-clusters="${MDB_CLUSTER_1_FULL_NAME},${MDB_CLUSTER_2_FULL_NAME}" \
  --member-cluster-namespace=${MDB_NS} \
  --central-cluster-namespace=${MDB_NS} \
  --create-service-account-secrets \
  --install-database-roles=true

printf "\n"
echo ">>> Add the MongoDB Helm Charts."
helm repo add mongodb https://mongodb.github.io/helm-charts

printf "\n"
echo ">>> Install operator in $MDB_NS namespace (required for creating OpsManager)"
helm upgrade \
  --install \
    mongodb-enterprise-operator-multi-cluster \
    mongodb/enterprise-operator \
      --namespace $MDB_NS \
      --set namespace=$MDB_NS \
      --set operator.name=mongodb-enterprise-operator-multi-cluster \
      --set operator.createOperatorServiceAccount=false \
      --set "multiCluster.clusters={$MDB_CLUSTER_1_FULL_NAME,$MDB_CLUSTER_2_FULL_NAME}" \
      --set multiCluster.performFailover=false


printf "\n"
echo ">>> Create ops manager secret."
kubectl -n "${MDB_NS}" create secret generic om-admin-secret \
  --from-literal=Username=$MDB_OM_USERNAME \
  --from-literal=Password=$MDB_OM_PASSWORD \
  --from-literal=FirstName="Ops" \
  --from-literal=LastName="Manager"

printf "\n"
echo ">>> Install OpsManager."
kubectl apply -f - <<EOF
apiVersion: mongodb.com/v1
kind: MongoDBOpsManager
metadata:
  name: ops-manager
  namespace: $MDB_NS
spec:
  version: $MDB_OM_VERSION
  # the name of the secret containing admin user credentials.
  adminCredentials: om-admin-secret
  externalConnectivity:
    type: LoadBalancer
  configuration:
    mms.ignoreInitialUiSetup: "true"
    automation.versions.source: mongodb
    mms.adminEmailAddr: support@example.com
    mms.fromEmailAddr: support@example.com
    mms.replyToEmailAddr: support@example.com
    mms.mail.hostname: example.com
    mms.mail.port: "465"
    mms.mail.ssl: "false"
    mms.mail.transport: smtp
  # the Replica Set backing Ops Manager.
  applicationDatabase:
    members: 3
    version: $MDB_APPDB_VERSION
EOF

printf "\n"
echo ">>> Wait for a few minutes for OpsManager to start (ops-manager-0 pod must be healthy) and creation of ops-manager-svc-ext service
>>> Before next step:
* Access OpsManager UI - use EXTERNAL-IP which should be assigned to ops-manager-svc-ext service (port 8080)
* Login using Username: $MDB_OM_USERNAME Password: $MDB_OM_PASSWORD
* Go to ops-manager-db organization
* From Organization -> Kubernetes Setup -> Generate Key and YAML -> save to .env file following:
* publicApiKey -> MDB_ORG_API_KEY
* orgId -> MDB_ORG_ID
* user -> MDB_ORG_USER
* For MDB_ORG_BASE_URL use OpsManager public URL (with port 8080)"
