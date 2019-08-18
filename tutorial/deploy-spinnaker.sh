#!/bin/bash

set -euo pipefail

current_dir="$(dirname $0)"

. "$current_dir/config.sh"

# gcloud projects create $PROJECT_ID

gcloud alpha billing projects link $PROJECT_ID --billing-account $GCP_BILLING_ACCOUNT_ID

(cd "$current_dir" \
    && terraform init \
    && terraform apply \
        -var="project_id=$PROJECT_ID" \
        -var="cluster_name=$CLUSTER_NAME" \
        -var="app_repo_name=$APP_REPO_NAME"
)

gcloud container clusters get-credentials $CLUSTER_NAME
kubectl port-forward svc/spin-deck $LOCAL_SPINNAKER_PORT:9000 >> /dev/null &
