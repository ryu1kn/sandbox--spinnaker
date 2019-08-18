#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

pipeline_file=__pipeline.json
spinnaker_gate_url=http://localhost:$LOCAL_SPINNAKER_PORT/gate

main() {
    download_sample_app
    initialise_app_repo
    push_tag
}

download_sample_app() {
    package_name=$APP_DIR.tgz
    wget -O $package_name https://gke-spinnaker.storage.googleapis.com/sample-app-v2.tgz
    mkdir $APP_DIR && tar xzfv $package_name -C $APP_DIR --strip-components 1
}

initialise_app_repo() {
    cd $APP_DIR

    git init
    git add .
    git commit -m "Initial commit"

    sed -i.bkp s/PROJECT/$PROJECT_ID/g k8s/deployments/* && rm -f k8s/deployments/*.bkp
    git commit -am "Set project ID"

    git remote add origin https://source.developers.google.com/p/$PROJECT_ID/r/$APP_REPO_NAME
    git config credential.helper gcloud.sh

    git push origin master
}

setup_spinnaker_pipeline() {
    spin application save --application-name sample \
        --owner-email example@example.com \
        --cloud-providers kubernetes \
        --gate-endpoint $spinnaker_gate_url

    sed s/PROJECT/$PROJECT_ID/g $APP_DIR/spinnaker/pipeline-deploy.json > $pipeline_file
    spin pipeline save --gate-endpoint $spinnaker_gate_url -f $pipeline_file
}

push_tag() {
    git tag v1.0.0
    git push --tags
}
