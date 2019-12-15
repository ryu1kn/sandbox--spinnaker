#!/bin/bash

set -euo pipefail

project_dir="$(dirname "$0")/.."
source "$project_dir/config.sh"

for script in "$spinnaker_dev_dir/scripts"/$1 ; do
    "$script"
done
