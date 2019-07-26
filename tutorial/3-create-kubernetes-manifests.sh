#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

##########################
## Prepare your Kubernetes Manifests for use in Spinnaker

gsutil mb -l $REGION gs://$KUBE_MANIFEST_BUCKET
gsutil versioning set on gs://$KUBE_MANIFEST_BUCKET

# In sample-app directory
cd $APP_DIR

sed -i .bkp s/PROJECT/$PROJECT/g k8s/deployments/* && rm -f k8s/deployments/*.bkp
git commit -a -m "Set project ID"

git tag v1.0.0
git push --tags
