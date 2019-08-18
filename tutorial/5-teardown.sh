#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

terraform destroy \
    -var="project_id=$PROJECT_ID" \
    -var="app_repo_name=APP_REPO_NAME"

gcloud alpha billing projects unlink $PROJECT_ID
