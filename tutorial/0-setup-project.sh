#!/bin/bash

set -euo pipefail

. "$(dirname $0)/config.sh"

# gcloud projects create $PROJECT

gcloud alpha billing projects link $PROJECT --billing-account $GCP_BILLING_ACCOUNT_ID
