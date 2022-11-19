output "managed_instance_group_urls" {
  description = "List of instance group URLs which have been assigned to this node pool."
  value       = google_container_node_pool.node_pool.managed_instance_group_urls
}
