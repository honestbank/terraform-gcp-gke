module "node_pools" {
  source   = "./modules/gcp-gke-node-pool"
  for_each = { for node_pool in var.additional_node_pools : node_pool.name => node_pool }

  providers = {
    google-beta = google-beta.compute-beta
  }

  name               = each.value.name
  machine_type       = each.value.machine_type
  maximum_node_count = each.value.maximum_node_count
  minimum_node_count = each.value.minimum_node_count
  taints             = each.value.taints
  tags               = concat([local.gke_node_pool_tag], each.value.tags)
  zones              = each.value.zones

  google_region               = var.google_region
  autoscaling_location_policy = var.autoscaling_location_policy
  cluster_name                = google_container_cluster.primary.name
  kubernetes_version          = var.kubernetes_version
  gcp_service_account_email   = google_service_account.default.email

  depends_on = [google_service_account.default]
}
