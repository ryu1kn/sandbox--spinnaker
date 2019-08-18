#!/bin/bash

set -euo pipefail

. "$(dirname $0)/config.sh"

# gcloud projects create $PROJECT_ID

gcloud alpha billing projects link $PROJECT_ID --billing-account $GCP_BILLING_ACCOUNT_ID

terraform init
terraform apply \
    -var="project_id=$PROJECT_ID" \
    -var="app_repo_name=APP_REPO_NAME"
