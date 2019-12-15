#!/bin/bash

set -euo pipefail

spinnaker_dev_dir="$HOME/dev/spinnaker"
spinnaker_extra_dir="$HOME/dev/spinnaker-extra"
spinnaker_data_dir="$spinnaker_extra_dir/spinnaker-data"
spinnaker_extra_log_dir="$spinnaker_extra_dir/logs"
spinnaker_branch="release-1.17.x"
halyard_repo_dir="$spinnaker_extra_dir/spinnaker-halyard"
halyard_config_dir="$spinnaker_extra_dir/halconfig"

services=(echo clouddriver deck fiat front50 gate igor orca rosco kayenta)
