#!/bin/bash

set -xeuo pipefail

##########################
## Building the Docker image

wget https://gke-spinnaker.storage.googleapis.com/sample-app-v2.tgz
tar xzfv sample-app-v2.tgz
cd sample-app

git init
git add .
git commit -m "Initial commit"

gcloud source repos create sample-app

git config credential.helper gcloud.sh

export PROJECT=$(gcloud info --format='value(config.project)')
git remote add origin https://source.developers.google.com/p/$PROJECT/r/sample-app

git push origin master

# https://cloud.google.com/solutions/continuous-delivery-spinnaker-kubernetes-engine#configure_your_build_triggers