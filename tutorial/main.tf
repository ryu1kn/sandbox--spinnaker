
variable "access_token" {}
variable "project_id" {}
variable "billing_account" {}
variable "pubsub_topic" {}
variable "pubsub_subscription" {}
variable "region" {}
variable "user_email" {}

locals {
  spinnaker_config_bucket = "${var.project_id}-spinnaker-config"
  cluster_node_count = 3
}

provider "google" {
  access_token = var.access_token
  project = var.project_id
  region = var.region
  zone = "${var.region}-a"
}

provider "google-beta" {
  access_token = var.access_token
  project = var.project_id
  region = var.region
  zone = "${var.region}-a"
}

resource "google_project" "my_project" {
  name = "Sandbox Spinnaker"
  project_id = var.project_id
  billing_account = var.billing_account
  skip_delete = true
}

resource "google_project_service" "googleapi_container" {
  service = "container.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "googleapi_cloudbuild" {
  service = "cloudbuild.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "googleapi_sourcerepo" {
  service = "sourcerepo.googleapis.com"
  disable_dependent_services = true
}

resource "google_container_cluster" "my_cluster" {
  name = "spinnaker-tutorial"
  initial_node_count = local.cluster_node_count
  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

resource "google_container_node_pool" "my_node_pool" {
  name = "my-node-pool"
  cluster = google_container_cluster.my_cluster.name
  node_count = local.cluster_node_count

  node_config {
    preemptible = true
    machine_type = "n1-standard-2"
  }
}

resource "google_service_account" "spinnaker_account" {
  account_id = "spinnaker-account"
}

resource "google_project_iam_member" "project" {
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.spinnaker_account.email}"
}

resource "google_service_account_key" "spinnaker_account_key" {
  service_account_id = google_service_account.spinnaker_account.name
}

resource "google_pubsub_topic" "pubsub_topic" {
  provider = "google-beta"
  name = var.pubsub_topic
}

resource "google_pubsub_subscription" "pubsub_subscription" {
  provider = "google-beta"
  name = var.pubsub_subscription
  topic = google_pubsub_topic.pubsub_topic.name
}

resource "google_pubsub_subscription_iam_member" "pubsub_role" {
  provider = "google-beta"
  subscription = google_pubsub_subscription.pubsub_subscription.name
  role = "roles/pubsub.subscriber"
  member = "serviceAccount:${google_service_account.spinnaker_account.email}"
}

resource "google_storage_bucket" "spinnaker_config_bucket" {
  name = local.spinnaker_config_bucket
  storage_class = "REGIONAL"
  location = var.region
}

provider "kubernetes" {
  load_config_file = false

  host = "https://${google_container_cluster.my_cluster.endpoint}"
  client_certificate = base64decode(google_container_cluster.my_cluster.master_auth.0.client_certificate)
  client_key = base64decode(google_container_cluster.my_cluster.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate)
}

# resource "kubernetes_cluster_role_binding" "example" {
#   metadata {
#     name = "user-admin-binding"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind = "ClusterRole"
#     name = "cluster-admin"
#   }
#   subject {
#     kind = "User"
#     name = var.user_email
#     api_group = "rbac.authorization.k8s.io"
#   }
# }
