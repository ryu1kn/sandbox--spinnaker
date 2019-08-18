variable "access_token" {
  type = string
  description = "Can be acquired with `gcloud auth print-access-token`"
}

variable "user_email" {
  type = string
  description = "Can be acquired with `gcloud config get-value account`"
}

variable "project_id" {
  type = string
  description = "Project's ID where Spinnaker will be deployed to"
}

variable "region" {
  type = string
  description = "Project's default region"
}

variable "cluster_name" {
  type = string
  description = "Cluster name where Spinnaker will be deployed to"
}

variable "pubsub_topic" {
  type = string
  description = "Pubsub topic which Spinnaker subscribe to"
}

variable "pubsub_subscription" {
  type = string
  description = "Pubsub subscription for Spinnaker"
}

variable "spinnaker_version" {
  type = string
  description = "Spinnaker version on Helm"
}

variable "halyard_version" {
  type = string
  description = "Halyard version"
}

variable "release_name" {
  type = string
  description = "Helm release name for Spinnaker"
}

variable "app_repo_name" {
  type = string
  description = "Sample app's repository name which Spinnaker deploys"
}
