#!/bin/bash

set -xeuo pipefail

region=australia-southeast1

##########################
## Prepare your Kubernetes Manifests for use in Spinnaker

export PROJECT=$(gcloud info --format='value(config.project)')
gsutil mb -l $region gs://$PROJECT-kubernetes-manifests
gsutil versioning set on gs://$PROJECT-kubernetes-manifests

# In sample-app directory
sed -i .bkp s/PROJECT/$PROJECT/g k8s/deployments/* && rm -f k8s/deployments/*.bkp
git commit -a -m "Set project ID"

git tag v1.0.0
git push --tags
