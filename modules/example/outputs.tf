output "ca_certificate" {
  sensitive = true
  value     = module.gke.ca_certificate
}

output "client_token" {
  sensitive = true
  value     = module.gke.client_token
}

output "cluster_name" {
  description = "The GKE cluster name that was built"
  value       = module.gke.cluster_name
}

output "cluster_project" {
  description = "The project hosting the GKE cluster."
  value       = module.gke.cluster_project
}

output "gke_cluster_primary_node_pool_tag" {
  description = "Tag applied to the node pool instances - used for network/firewall rules."
  value       = module.gke.cluster_primary_node_pool_tag
}

output "kubernetes_endpoint" {
  sensitive = true
  value     = module.gke.kubernetes_endpoint
}

output "service_account" {
  description = "The default service account used for running nodes."
  value       = module.gke.node_pool_service_account_email
}

output "cluster_primary_node_pool_tag" {
  description = "Tag applied to the node pool instances - used for network/firewall rules."
  value       = module.gke.cluster_primary_node_pool_tag
}

output "cluster_all_primary_node_pool_tags" {
  description = "List of tags applied to the node pool instances. This included the managed-by-GCP tags."
  value       = module.gke.cluster_all_primary_node_pool_tags
}
