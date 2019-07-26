#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

spinnaker_version=1.10.2
spinnaker_key=__spinnaker-sa.json
spinnaker_config=__spinnaker-config.yaml

##########################
## Set up your environment

# Create a GKE cluster
gcloud config set compute/zone $REGION
gcloud container clusters create $CLUSTER_NAME --machine-type=n1-standard-2

# Configure identity and access management
gcloud iam service-accounts create spinnaker-account --display-name spinnaker-account
gcloud projects add-iam-policy-binding $PROJECT --role roles/storage.admin --member serviceAccount:$SA_EMAIL
gcloud iam service-accounts keys create $spinnaker_key --iam-account $SA_EMAIL

# Set up Cloud Pub/Sub to trigger Spinnaker pipelines
gcloud beta pubsub topics create projects/$PROJECT/topics/gcr
gcloud beta pubsub subscriptions create gcr-triggers --topic projects/${PROJECT}/topics/gcr
gcloud beta pubsub subscriptions add-iam-policy-binding gcr-triggers --role roles/pubsub.subscriber --member serviceAccount:$SA_EMAIL

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
gsutil mb -c regional -l $REGION gs://$BUCKET
sa_json=$(cat $spinnaker_key)

cat > $spinnaker_config <<EOF
gcs:
  enabled: true
  bucket: $BUCKET
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
  spinnakerVersion: $spinnaker_version
  image:
    tag: 1.12.0
  additionalScripts:
    create: true
    data:
      enable_gcs_artifacts.sh: |-
        \$HAL_COMMAND config artifact gcs account add gcs-$PROJECT --json-path /opt/gcs/key.json
        \$HAL_COMMAND config artifact gcs enable
      enable_pubsub_triggers.sh: |-
        \$HAL_COMMAND config pubsub google enable
        \$HAL_COMMAND config pubsub google subscription add gcr-triggers \
          --subscription-name gcr-triggers \
          --json-path /opt/gcs/key.json \
          --project $PROJECT \
          --message-format GCR
EOF

# Deploy the Spinnaker chart
helm install --name $RELEASE_NAME stable/spinnaker -f $spinnaker_config --version $spinnaker_version --timeout 600 --wait
deck_pod=$(kubectl get pods --namespace default -l "cluster=spin-deck" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace default $deck_pod 8080:9000 >> /dev/null &
