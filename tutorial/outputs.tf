output "cluster_ca_cert" {
  description = "Cluster's CA certificate"
  value = base64decode(google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate)
}

output "cluster_ip" {
  description = "Cluster's IP"
  value = "https://${google_container_cluster.my_cluster.endpoint}"
}
