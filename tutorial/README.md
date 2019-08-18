
# Spinnaker on Google Cloud Platform

The scripts here started as the copy-paste of commands on article [Continuous Delivery Pipelines with Spinnaker and Google Kubernetes Engine](https://cloud.google.com/solutions/continuous-delivery-spinnaker-kubernetes-engine).

Gradually I replaced UI operations with cli commands to easily deploy/delete new Spinnaker environment to do experiment.

## Prerequisites

* Docker
* [Terraform](https://www.terraform.io)
* [Spin CLI](https://www.spinnaker.io/guides/spin/)
* `jq`: `brew install jq`
* Environment variable `GCP_BILLING_ACCOUNT_ID` is set
* Authenticated to GCP with `gcloud auth login`

## Setup Spinnaker

1. Create a project on GCP if you want to deploy to a new one.
1. Modify [`config.sh`](./config.sh) and [`config.auto.tfvars`](./config.auto.tfvars) as you like.
1. Set following environment variables:

    ```sh
    export PROJECT_ID="project-id-where-i-deploy-spinnaker-to"
    export TF_VAR_access_token="$(gcloud auth print-access-token)"
    export TF_VAR_user_email="$(gcloud config get-value account)"
    ```

1. Run `deploy-spinnaker.sh`.

    **Note**: The command may fail with the following error. Just re-run the script, it should succeed.

    ```
    Error: Error creating Repository: googleapi: Error 403: Cloud Source Repositories API has not been used in project 999999999999 before or it is disabled. Enable it by visiting https://console.cloud.google.com/apis/api/sourcerepo.googleapis.com/overview?project=999999999999 then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.

      on main.tf line 243, in resource "google_sourcerepo_repository" "my-repo":
     243: resource "google_sourcerepo_repository" "my-repo" {



    Error: Error creating Trigger: googleapi: Error 403: Access Not Configured. Cloud Build has not been used in project your-spinnaker-project before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/cloudbuild.googleapis.com/overview?project=your-spinnaker-project then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.

      on main.tf line 258, in resource "google_cloudbuild_trigger" "trigger":
     258: resource "google_cloudbuild_trigger" "trigger" {
    ```

1. Deploy sample app and its spinnaker pipeline by running `create-pipeline.sh`.
1. Open http://localhost:8080 and you'll see Spinnaker UI.

## Teardown Spinnaker

1. Run `destroy-spinnaker.sh`

## Refs

* [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/)
