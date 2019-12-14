#!/bin/bash

set -euo pipefail

project_dir="$(dirname "$0")/.."
source "$project_dir/config.sh"
source "$project_dir/lib/log.sh"

spinnaker_version=${1:-1.16.6}
bom_file="bom-$spinnaker_version.yaml"

info "Checking out Spinnaker version $spinnaker_version"

if [[ ! -e "$bom_file" ]] ; then
    hal version bom "$spinnaker_version" -q -o yaml > "$bom_file"
fi

get_service_sha() {
    local service=$1
    yq r "$bom_file" "services.$service.commit"
}

for service in "${services[@]}" ; do
    sha=$(get_service_sha "$service")

    info "Setting \"$service\" to \"$sha\""
    (cd "$spinnaker_dev_dir/$service" && git checkout "$sha")
done
