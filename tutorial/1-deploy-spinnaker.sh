#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"
. "$(dirname $0)/lib/helpers.sh"

spinnaker_key=__spinnaker-sa.json
spinnaker_config=__spinnaker-config.yaml

# Create a GKE cluster
gcloud config set compute/zone $ZONE
gcloud container clusters create $CLUSTER_NAME --machine-type=n1-standard-2

# Configure identity and access management
gcloud iam service-accounts create spinnaker-account --display-name $SERVICE_ACCOUNT_DISPLAY_NAME
while [[ "${sa_email:-}" = "" ]]
do
    sa_email=$(getServiceAccountEmail $SERVICE_ACCOUNT_DISPLAY_NAME)
    sleep $API_RETRY_INTERVAL_SEC
done

gcloud projects add-iam-policy-binding $PROJECT --role roles/storage.admin --member serviceAccount:$sa_email
gcloud iam service-accounts keys create $spinnaker_key --iam-account $sa_email

# Set up Cloud Pub/Sub to trigger Spinnaker pipelines
gcloud beta pubsub topics create projects/$PROJECT/topics/$PUBSUB_TOPIC
gcloud beta pubsub subscriptions create $PUBSUB_SUBSCRIPTION --topic projects/${PROJECT}/topics/$PUBSUB_TOPIC
gcloud beta pubsub subscriptions add-iam-policy-binding $PUBSUB_SUBSCRIPTION --role roles/pubsub.subscriber --member serviceAccount:$sa_email

##################################
## Deploying Spinnaker using Helm

# Install Helm
kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl create clusterrolebinding --clusterrole=cluster-admin --serviceaccount=default:default spinnaker-admin
helm init --service-account=tiller --wait
helm update
helm version

# Configure Spinnaker
gsutil mb -c regional -l $REGION gs://$SPINNAKER_CONFIG_BUCKET
sa_json=$(cat $spinnaker_key)

cat > $spinnaker_config <<EOF
gcs:
  enabled: true
  bucket: $SPINNAKER_CONFIG_BUCKET
  project: $PROJECT
  jsonKey: '$sa_json'

dockerRegistries:
- name: gcr
  address: https://gcr.io
  username: _json_key
  password: '$sa_json'
  email: 1234@5678.com

# Disable minio as the default storage backend
minio:
  enabled: false

# Configure Spinnaker to enable GCP services
halyard:
  spinnakerVersion: $SPINNAKER_VERSION
  image:
    tag: $HALYARD_VERSION
  additionalScripts:
    create: true
    data:
      enable_gcs_artifacts.sh: |-
        \$HAL_COMMAND config artifact gcs account add gcs-$PROJECT --json-path /opt/gcs/key.json
        \$HAL_COMMAND config artifact gcs enable
      enable_pubsub_triggers.sh: |-
        \$HAL_COMMAND config pubsub google enable
        \$HAL_COMMAND config pubsub google subscription add $PUBSUB_SUBSCRIPTION \
          --subscription-name $PUBSUB_SUBSCRIPTION \
          --json-path /opt/gcs/key.json \
          --project $PROJECT \
          --message-format GCR
      enable_pipeline_template.sh: |-
        \$HAL_COMMAND config features edit --pipeline-templates true
        \$HAL_COMMAND config features edit --managed-pipeline-templates-v2-ui true
EOF

# Deploy the Spinnaker chart
helm install --name $RELEASE_NAME stable/spinnaker -f $spinnaker_config --version $SPINNAKER_VERSION --timeout 600 --wait
deck_pod=$(kubectl get pods --namespace default -l "cluster=spin-deck" -o jsonpath="{.items[0].metadata.name}")
until [[ "${deck_pod_ready:-}" = true ]]
do
    deck_pod_ready=$(kubectl get pods $deck_pod --namespace default -o jsonpath='{.status.containerStatuses.*.ready}')
    sleep $API_RETRY_INTERVAL_SEC
done
kubectl port-forward --namespace default $deck_pod $SPINNAKER_LOCAL_MAP_PORT:9000 >> /dev/null &
