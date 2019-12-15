#!/bin/bash

set -euo pipefail

readonly project_dir="$(dirname "$0")"
source "$project_dir/config.sh"

readonly hal="$project_dir/tools/hal"
readonly minio_endpoint=http://127.0.0.1:8888
readonly halyard_deployment_dir="$halyard_config_dir/default"
readonly local_k8s_account=my-k8s-v2-account

mkdir -p "$halyard_deployment_dir" "$spinnaker_extra_log_dir" "$spinnaker_data_dir"
cp -rf halyard-deployment/* "$halyard_deployment_dir/"

minio server --address "${minio_endpoint##*/}" "$spinnaker_data_dir" \
    > "$spinnaker_extra_log_dir/minio.log" 2> "$spinnaker_extra_log_dir/minio.err" &

if [[ ! -d "$halyard_repo_dir" ]] ; then
    git clone "git://github.com/$GITHUB_USERNAME/halyard.git" "$halyard_repo_dir"
fi

(cd "$halyard_repo_dir" && ./gradlew build)

(cd "$halyard_repo_dir" \
    && SPRING_APPLICATION_JSON="{\"halyard\":{\"halconfig\":{\"directory\":\"$halyard_config_dir\"}}}" ./gradlew \
        > "$spinnaker_extra_log_dir/halyard.log" 2> "$spinnaker_extra_log_dir/halyard.err") &
until fgrep ': Started Main' "$spinnaker_extra_log_dir/halyard.log" ; do
    echo 'Waiting for Halyard daemon to start...'
    sleep 3
done

"$hal" config storage s3 edit --endpoint "$minio_endpoint" \
    --access-key-id "$MINIO_ACCESS_KEY" \
    --secret-access-key <<< "$MINIO_SECRET_KEY"
"$hal" config storage edit --type s3

if [[ -z "$(docker ps --filter name=kind-control-plane -q)" ]] ; then
    kind create cluster
fi
kind export kubeconfig

if "$hal" config provider kubernetes account list | fgrep "$local_k8s_account" ; then
    "$hal" config provider kubernetes account delete "$local_k8s_account"
fi
"$hal" config provider kubernetes account add "$local_k8s_account" \
    --provider-version v2 \
    --context "$(kubectl config current-context)"
"$hal" config provider kubernetes enable

"$hal" config security ui edit --override-base-url http://localhost:9000
"$hal" config security api edit --override-base-url http://localhost:8084

"$hal" config features edit --artifacts true
"$hal" config deploy edit --type localgit --git-origin-user="$GITHUB_USERNAME"
"$hal" config version edit --version "branch:$spinnaker_branch"

cat << EOF
Deploy Spinnaker with: tools/hal deploy apply
EOF
