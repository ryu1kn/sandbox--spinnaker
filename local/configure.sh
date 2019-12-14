#!/bin/bash

set -euo pipefail

project_dir="$(dirname "$0")"
source "$project_dir/config.sh"

minio_endpoint=http://192.168.0.4:8888
halyard_deployment_dir="$HOME/.hal/default"

cp -rf halyard-deployment/* "$halyard_deployment_dir"

mkdir -p "$spinnaker_data_dir"
minio server "$spinnaker_data_dir"

hal config storage edit --type s3
hal config storage s3 edit --endpoint "$minio_endpoint" \
    --access-key-id "$MINIO_ACCESS_KEY" \
    --secret-access-key <<< "$MINIO_SECRET_KEY"

if [[ -z "$(docker ps --filter name=kind-control-plane -q)" ]] ; then
    kind create cluster
fi
kind export kubeconfig

hal config provider kubernetes enable
hal config provider kubernetes account add my-k8s-v2-account \
    --provider-version v2 \
    --context "$(kubectl config current-context)"

hal config security ui edit --override-base-url http://localhost:9000
hal config security api edit --override-base-url http://localhost:8084

hal config features edit --artifacts true
hal config deploy edit --type localgit --git-origin-user="$GITHUB_USERNAME"
hal config version edit --version branch:upstream/master
