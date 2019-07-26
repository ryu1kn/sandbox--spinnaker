#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

helm delete --purge $RELEASE_NAME
kubectl delete -f k8s/services
gcloud projects remove-iam-policy-binding $PROJECT --role roles/storage.admin --member serviceAccount:$SA_EMAIL
gcloud iam service-accounts delete $SA_EMAIL
gcloud container clusters delete $CLUSTER_NAME --zone=$REGION
gcloud source repos delete $APP_REPO_NAME
gsutil -m rm -r gs://$SPINNAKER_CONFIG_BUCKET

gcloud container images delete gcr.io/$PROJECT/$APP_REPO_NAME:v1.0.0
# Remove all the other tags if exist
