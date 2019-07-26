#!/bin/bash

set -euo pipefail

getServiceAccountEmail() {
    local display_name=$1
    gcloud iam service-accounts list --filter="displayName:$display_name" --format='value(email)'
}
