output "kubernetes_endpoint" {
  description = "The kubernetes_endpoint output of the google_container_cluster resource."
  value       = google_container_cluster.primary.endpoint
}

output "client_token" {
  sensitive = true
  value     = data.google_client_config.default.access_token
}

output "ca_certificate" {
  sensitive = true
  value     = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

output "node_pool_service_account_email" {
  description = "The default service account used for running nodes"
  value       = google_service_account.default.email
}

output "cluster_name" {
  description = "The GKE cluster name that was built"
  value       = google_container_cluster.primary.name
}

output "cluster_project" {
  description = "The project hosting the GKE cluster."
  value       = google_container_cluster.primary.project
}

output "cluster_primary_node_pool_tag" {
  description = "Tag applied to the node pool instances - used for network/firewall rules."
  value       = local.gke_node_pool_tag
}

output "cluster_all_primary_node_pool_tags" {
  description = "List of tags applied to the node pool instances. This included the managed-by-GCP tags."
  value       = local.all_primary_node_pool_tags
}

output "istio_gatekeeper_firewall_rule_self_link" {
  description = "The self_link attribute of the firewall rule created to allow Gatekeeper and Istio to function."
  value       = google_compute_firewall.gke_private_cluster_istio_gatekeeper_rules.self_link
}
