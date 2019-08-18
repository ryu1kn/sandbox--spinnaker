#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

cd $APP_DIR

sed -i .bkp s/PROJECT/$PROJECT_ID/g k8s/deployments/* && rm -f k8s/deployments/*.bkp
git commit -a -m "Set project ID"

git tag v1.0.0
git push --tags
