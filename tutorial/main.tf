terraform {
  required_providers {
    helm = "0.10.2"
    template = "2.1.2"
    kubernetes = "1.8.1"

    # Stay on 2.12 for now
    # https://github.com/terraform-providers/terraform-provider-google/issues/4276
    google = "2.12.0"
    google-beta = "2.12.0"
  }
}

variable "access_token" {}
variable "project_id" {}
variable "pubsub_topic" {}
variable "pubsub_subscription" {}
variable "region" {}
variable "user_email" {}
variable "release_name" {}
variable "spinnaker_version" {}
variable "halyard_version" {}
variable "app_repo_name" {}

locals {
  spinnaker_config_bucket = "${var.project_id}-spinnaker-config"
  kube_manifest_bucket = "${var.project_id}-kubernetes-manifests"
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

data "google_project" "my_project" {
  project_id = var.project_id
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
  remove_default_node_pool = true
  initial_node_count = 1
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
    # https://developers.google.com/identity/protocols/googlescopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_service_account" "spinnaker_account" {
  account_id = "spinnaker-account"
  display_name = "spinnaker-account"
}

resource "google_project_iam_binding" "spinnaker_account" {
  role = "roles/storage.admin"
  members = ["serviceAccount:${google_service_account.spinnaker_account.email}"]
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

resource "google_pubsub_subscription_iam_binding" "pubsub_role" {
  provider = "google-beta"
  subscription = google_pubsub_subscription.pubsub_subscription.name
  role = "roles/pubsub.subscriber"
  members = ["serviceAccount:${google_service_account.spinnaker_account.email}"]
}

resource "google_storage_bucket" "spinnaker_config_bucket" {
  name = local.spinnaker_config_bucket
  storage_class = "REGIONAL"
  location = var.region
  force_destroy = true
}

provider "kubernetes" {
  load_config_file = false

  host = "https://${google_container_cluster.my_cluster.endpoint}"

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "bash"
    args = [
      "-c",
      "gcloud config config-helper --format=json | jq '{apiVersion: \"client.authentication.k8s.io/v1beta1\", kind: \"ExecCredential\", status: {token: .credential.access_token, expirationTimestamp: .credential.token_expiry}}'"
    ]
  }
  cluster_ca_certificate = base64decode(google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate)
}

resource "kubernetes_cluster_role_binding" "user_admin_binding" {
  metadata {
    name = "user-admin-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "User"
    name = var.user_email
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller_admin_binding" {
  metadata {
    name = "tiller-admin-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.tiller.metadata.0.name
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "spinnaker_admin_binding" {
  metadata {
    name = "spinnaker-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = "default"
    namespace = "default"
  }
}

provider "helm" {
  service_account = kubernetes_service_account.tiller.metadata.0.name
  automount_service_account_token = true
  debug = true
  kubernetes {
    host = "https://${google_container_cluster.my_cluster.endpoint}"
    token = var.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate)
  }
}

data "helm_repository" "canonical" {
  name = "canonical"
  url = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "spinnaker" {
  depends_on = [
    google_container_node_pool.my_node_pool,
    google_project_iam_binding.spinnaker_account,
    kubernetes_cluster_role_binding.user_admin_binding,
    kubernetes_cluster_role_binding.tiller_admin_binding,
    kubernetes_cluster_role_binding.spinnaker_admin_binding
  ]
  name = var.release_name
  repository = "${data.helm_repository.canonical.metadata.0.name}"
  chart = "stable/spinnaker"
  version = var.spinnaker_version
  timeout = 600

  values = [
    data.template_file.spinnaker_config.rendered
  ]
}

data "template_file" "spinnaker_config" {
  template = file("spinnaker-config.yaml")
  vars = {
    sa_json = base64decode(google_service_account_key.spinnaker_account_key.private_key)
    spinnaker_config_bucket = local.spinnaker_config_bucket
    project_id = var.project_id
    spinnaker_version = var.spinnaker_version
    halyard_version = var.halyard_version
    pubsub_subscription = var.pubsub_subscription
  }
}

resource "google_sourcerepo_repository" "my-repo" {
  provider = "google-beta"
  name = var.app_repo_name
}

resource "google_storage_bucket" "kube_manifest_bucket" {
  name = local.kube_manifest_bucket
  storage_class = "REGIONAL"
  location = var.region
  versioning {
    enabled = true
  }
  force_destroy = true
}

resource "google_cloudbuild_trigger" "trigger" {
  provider = "google-beta"

  description = "Push to v.* tag"
  trigger_template {
    project_id = var.project_id
    tag_name = "v.*"
    repo_name = var.app_repo_name
  }
  filename = "cloudbuild.yaml"
}
