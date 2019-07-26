#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

##########################
## Prepare your Kubernetes Manifests for use in Spinnaker

export PROJECT=$(gcloud info --format='value(config.project)')
gsutil mb -l $REGION gs://$PROJECT-kubernetes-manifests
gsutil versioning set on gs://$PROJECT-kubernetes-manifests

# In sample-app directory
sed -i .bkp s/PROJECT/$PROJECT/g k8s/deployments/* && rm -f k8s/deployments/*.bkp
git commit -a -m "Set project ID"

git tag v1.0.0
git push --tags
