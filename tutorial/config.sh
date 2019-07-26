#!/bin/bash

RELEASE_NAME=cd
REGION=australia-southeast1
CLUSTER_NAME=spinnaker-tutorial
APP_REPO_NAME=sample-app

PROJECT=$(gcloud info --format='value(config.project)')
SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:spinnaker-account" --format='value(email)')
BUCKET=$PROJECT-spinnaker-config
