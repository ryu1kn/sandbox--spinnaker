#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"
. "$(dirname $0)/lib/helpers.sh"

helm delete --purge $RELEASE_NAME
kubectl delete -f $APP_DIR/k8s/services

sa_email=$(getServiceAccountEmail $SERVICE_ACCOUNT_DISPLAY_NAME)
gcloud projects remove-iam-policy-binding $PROJECT --role roles/storage.admin --member serviceAccount:$sa_email
gcloud iam service-accounts delete $sa_email

gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE
gcloud source repos delete $APP_REPO_NAME
gsutil -m rm -r gs://$SPINNAKER_CONFIG_BUCKET
gsutil -m rm -r gs://$KUBE_MANIFEST_BUCKET

gcloud container images delete gcr.io/$PROJECT/$APP_REPO_NAME:v1.0.0
# Remove all the other tags if exist

gcloud services disable container.googleapis.com cloudbuild.googleapis.com sourcerepo.googleapis.com
gcloud alpha billing projects unlink sandbox--spinnaker
