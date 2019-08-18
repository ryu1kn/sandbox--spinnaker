#!/bin/bash

set -xeuo pipefail

. "$(dirname $0)/config.sh"

gcloud alpha billing projects unlink $PROJECT
