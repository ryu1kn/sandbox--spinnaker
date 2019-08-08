#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

##########################
## Configuring your deployment pipelines
pipeline_file=__pipeline.json
spinnaker_gate_url=http://localhost:$SPINNAKER_LOCAL_MAP_PORT/gate

cd $APP_DIR

spin application save --application-name sample \
    --owner-email example@example.com \
    --cloud-providers kubernetes \
    --gate-endpoint $spinnaker_gate_url
sed s/PROJECT/$PROJECT/g spinnaker/pipeline-deploy.json > $pipeline_file
spin pipeline save --gate-endpoint $spinnaker_gate_url -f $pipeline_file