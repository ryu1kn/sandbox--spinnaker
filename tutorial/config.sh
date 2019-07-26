#!/bin/bash

RELEASE_NAME=cd
REGION=australia-southeast1

PROJECT=$(gcloud info --format='value(config.project)')
SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:spinnaker-account" --format='value(email)')
