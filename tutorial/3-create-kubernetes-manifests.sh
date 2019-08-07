#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

cloudbuild_trigger_config=__cloudbuild-trigger.yaml

##########################
## Prepare your Kubernetes Manifests for use in Spinnaker

gsutil mb -l $REGION gs://$KUBE_MANIFEST_BUCKET
gsutil versioning set on gs://$KUBE_MANIFEST_BUCKET

cat <<EOF > $cloudbuild_trigger_config
description: Push to v.* tag
filename: cloudbuild.yaml
triggerTemplate:
  projectId: $PROJECT
  repoName: $APP_REPO_NAME
  tagName: v.*
EOF
gcloud alpha builds triggers create cloud-source-repositories --trigger-config=$cloudbuild_trigger_config

# In sample-app directory
cd $APP_DIR

sed -i .bkp s/PROJECT/$PROJECT/g k8s/deployments/* && rm -f k8s/deployments/*.bkp
git commit -a -m "Set project ID"

git tag v1.0.0
git push --tags
