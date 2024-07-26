resource "google_container_node_pool" "node_pool" {
  provider = google-beta

  name     = var.name
  location = var.google_region
  version  = var.kubernetes_version

  node_locations = var.zones
  node_count     = var.minimum_node_count
  cluster        = var.cluster_name

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
      # checkov:skip=CKV_GCP_68: Accomodates prometheus node pool TF import
      enable_secure_boot          = var.enable_secure_boot
      enable_integrity_monitoring = true
    }

    metadata = {
      # disable-legacy-endpoints defaults to `true` since GKE 1.12. However if the metadata block is used without
      # sending this value, Terraform will try to unset it.
      # Also, tfsec complains: https://aquasecurity.github.io/tfsec/v1.27.6/checks/google/gke/metadata-endpoints-disabled/
      # So leave this here in case we add metadata in the future.
      disable-legacy-endpoints = true
    }

    # Use a conditional expression to add the taint only if the 'taint' variable is non-empty
    dynamic "taint" {
      for_each = var.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    tags = var.tags
  }

  timeouts {
    create = var.nodepool_ops_timeouts.create
    update = var.nodepool_ops_timeouts.update
    delete = var.nodepool_ops_timeouts.delete
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      node_count,
      version,
    ]
  }
}
