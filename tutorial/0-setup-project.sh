#!/bin/bash

set -euo pipefail

. "$(dirname $0)/config.sh"

gcloud projects create $PROJECT
gcloud config set project $PROJECT

gcloud services enable container.googleapis.com cloudbuild.googleapis.com sourcerepo.googleapis.com
gcloud alpha billing projects link $PROJECT --billing-account $GCP_BILLING_ACCOUNT_ID
