#!/bin/bash

set -euo pipefail

spinnaker_dev_dir="$HOME/dev/spinnaker"
spinnaker_data_dir="$HOME/dev/spinnaker-data"

services=(echo clouddriver deck fiat front50 gate igor orca rosco kayenta)
