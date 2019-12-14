#!/bin/bash

set -euo pipefail

project_dir="$(dirname "$0")/.."
source "$project_dir/config.sh"
source "$project_dir/lib/log.sh"

for service in "${services[@]}" ; do
    info "Cleaning \"$service\""
    (cd "$spinnaker_dev_dir/$service" && ./gradlew clean)

    info "Starting \"$service\""
    (cd "$spinnaker_dev_dir/$service" && ./gradlew)
done
