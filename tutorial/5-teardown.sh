#!/bin/bash

set -xeuo pipefail

region=australia-southeast1

helm delete --purge cd
kubectl delete -f k8s/services
export SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:spinnaker-account" --format='value(email)')
export PROJECT=$(gcloud info --format='value(config.project)')
gcloud projects remove-iam-policy-binding $PROJECT --role roles/storage.admin --member serviceAccount:$SA_EMAIL
export SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:spinnaker-account" --format='value(email)')
gcloud iam service-accounts delete $SA_EMAIL
gcloud container clusters delete spinnaker-tutorial --zone=$region
gcloud source repos delete sample-app
export PROJECT=$(gcloud info --format='value(config.project)')
export BUCKET=$PROJECT-spinnaker-config
gsutil -m rm -r gs://$BUCKET
export PROJECT=$(gcloud info --format='value(config.project)')

gcloud container images delete gcr.io/$PROJECT/sample-app:v1.0.0
# Remove all the other tags if exist
