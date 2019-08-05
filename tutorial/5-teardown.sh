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

image=gcr.io/$PROJECT/$APP_REPO_NAME
for digest in $(gcloud container images list-tags $image --format='value(digest)')
do
    gcloud container images delete -q --force-delete-tags "$image@sha256:$digest"
done

gcloud services disable container.googleapis.com cloudbuild.googleapis.com sourcerepo.googleapis.com
gcloud alpha billing projects unlink $PROJECT
