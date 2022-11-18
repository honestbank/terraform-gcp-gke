resource "google_container_node_pool" "node_pool" {
  provider = google-beta

  name     = var.name
  location = var.google_region
  version = var.kubernetes_version

  node_locations = [
    "${var.google_region}-a",
    "${var.google_region}-b",
    "${var.google_region}-c",
  ]

  node_count = var.minimum_node_count
  cluster    = var.cluster_name

  autoscaling {
    max_node_count  = var.maximum_node_count
    min_node_count  = var.minimum_node_count
    location_policy = var.autoscaling_location_policy
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = var.gcp_service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    tags = var.tags
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      node_count,
    ]
  }
}
