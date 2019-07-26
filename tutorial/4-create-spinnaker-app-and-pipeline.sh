#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

##########################
## Configuring your deployment pipelines

spin application save --application-name sample \
    --owner-email example@example.com \
    --cloud-providers kubernetes \
    --gate-endpoint http://localhost:8080/gate
sed s/PROJECT/$PROJECT/g spinnaker/pipeline-deploy.json > pipeline.json
spin pipeline save --gate-endpoint http://localhost:8080/gate -f pipeline.json
