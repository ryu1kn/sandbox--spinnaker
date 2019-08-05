#!/bin/bash

REGION=australia-southeast1
ZONE=$REGION-a

CLUSTER_NAME=spinnaker-tutorial
SERVICE_ACCOUNT_DISPLAY_NAME=spinnaker-account
RELEASE_NAME=cd
APP_REPO_NAME=sample-app

PROJECT=sandbox--spinnaker
SPINNAKER_CONFIG_BUCKET=$PROJECT-spinnaker-config
KUBE_MANIFEST_BUCKET=$PROJECT-kubernetes-manifests
APP_DIR=__sample-app
