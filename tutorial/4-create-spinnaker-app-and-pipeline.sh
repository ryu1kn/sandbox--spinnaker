#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

##########################
## Configuring your deployment pipelines
pipeline_file=__pipeline.json

cd $APP_DIR

spin application save --application-name sample \
    --owner-email example@example.com \
    --cloud-providers kubernetes \
    --gate-endpoint http://localhost:8080/gate
sed s/PROJECT/$PROJECT/g spinnaker/pipeline-deploy.json > $pipeline_file
spin pipeline save --gate-endpoint http://localhost:8080/gate -f $pipeline_file
