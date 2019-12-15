#!/bin/bash

set -euo pipefail

project_dir="$(dirname "$0")/.."
source "$project_dir/config.sh"
source "$project_dir/lib/log.sh"

should_clean="${1:-false}"

for service in "${services[@]}" ; do
    [[ "$service" = deck ]] && continue

    if [[ "$should_clean" = true ]] ; then
        info "Cleaning \"$service\""
        (cd "$spinnaker_dev_dir/$service" && ./gradlew clean)
    fi

    info "Building \"$service\""
    (cd "$spinnaker_dev_dir/$service" && ./gradlew build)
done
