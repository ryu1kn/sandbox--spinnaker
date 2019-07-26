#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

##########################
## Building the Docker image

wget https://gke-spinnaker.storage.googleapis.com/sample-app-v2.tgz
tar xzfv sample-app-v2.tgz
cd sample-app

git init
git add .
git commit -m "Initial commit"

gcloud source repos create $APP_REPO_NAME

git config credential.helper gcloud.sh

git remote add origin https://source.developers.google.com/p/$PROJECT/r/$APP_REPO_NAME

git push origin master

# https://cloud.google.com/solutions/continuous-delivery-spinnaker-kubernetes-engine#configure_your_build_triggers
