#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

##########################
## Building the Docker image

package_name=$APP_DIR.tgz

wget -O $package_name https://gke-spinnaker.storage.googleapis.com/sample-app-v2.tgz
mkdir $APP_DIR && tar xzfv $package_name -C $APP_DIR --strip-components 1

cd $APP_DIR

git init
git add .
git commit -m "Initial commit"

gcloud source repos create $APP_REPO_NAME

git config credential.helper gcloud.sh

git remote add origin https://source.developers.google.com/p/$PROJECT/r/$APP_REPO_NAME

git push origin master
