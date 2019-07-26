#!/bin/bash

set -xeuo pipefail

##########################
## Configuring your deployment pipelines

spin application save --application-name sample \
    --owner-email example@example.com \
    --cloud-providers kubernetes \
    --gate-endpoint http://localhost:8080/gate
export PROJECT=$(gcloud info --format='value(config.project)')
sed s/PROJECT/$PROJECT/g spinnaker/pipeline-deploy.json > pipeline.json
spin pipeline save --gate-endpoint http://localhost:8080/gate -f pipeline.json
