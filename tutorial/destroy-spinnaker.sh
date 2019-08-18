#!/bin/bash

set -xeuo pipefail

current_dir="$(dirname $0)"

. "$current_dir/config.sh"

(cd "$current_dir" \
    && terraform destroy \
        -var="project_id=$PROJECT_ID" \
        -var="app_repo_name=APP_REPO_NAME"
)

rm -rf "$APP_DIR"

gcloud alpha billing projects unlink $PROJECT_ID
