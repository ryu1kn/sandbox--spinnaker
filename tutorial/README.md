
# Spinnaker on Google Cloud Platform

The scripts here started as the copy-paste of commands on article [Continuous Delivery Pipelines with Spinnaker and Google Kubernetes Engine](https://cloud.google.com/solutions/continuous-delivery-spinnaker-kubernetes-engine).

Gradually I replaced UI operations with cli commands to easily deploy/delete new Spinnaker environment to do experiment.

## Prerequisites

* Docker
* [helm](https://helm.sh/)
* [Spin CLI](https://www.spinnaker.io/guides/spin/)
* `jq`: `brew install jq`
* [Terraform](https://www.terraform.io)
* Environment variable `GCP_BILLING_ACCOUNT_ID` is set
* Authenticated to GCP with `gcloud auth login`

## Setup Spinnaker

1. Create a project on GCP if you want to deploy to a new one.
1. Modify [`config.sh`](./config.sh) and [`config.auto.tfvars`](./config.auto.tfvars) as you like.
1. Set following environment variables:

    ```sh
    export TF_VAR_access_token="$(gcloud auth print-access-token)"
    export TF_VAR_user_email="$(gcloud config get-value account)"
    ```

1. Run scripts one-by-one in order except `*-teardown.sh`.
1. Open http://localhost:8080 and you'll see Spinnaker UI.

## Teardown Spinnaker

1. Run `*-teardown.sh`
