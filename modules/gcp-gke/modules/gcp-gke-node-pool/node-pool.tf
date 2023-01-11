resource "google_container_node_pool" "node_pool" {
  project = var.google_project

  name     = var.name
  location = var.google_region
  version  = var.kubernetes_version

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

    metadata = {
      # disable-legacy-endpoints defaults to `true` since GKE 1.12. However if the metadata block is used without
      # sending this value, Terraform will try to unset it.
      # Also, tfsec complains: https://aquasecurity.github.io/tfsec/v1.27.6/checks/google/gke/metadata-endpoints-disabled/
      # So leave this here in case we add metadata in the future.
      disable-legacy-endpoints = true
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
