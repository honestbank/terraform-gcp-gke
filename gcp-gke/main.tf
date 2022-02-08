terraform {
  required_version = "~> 1.0"

  required_providers {
    google = {
      version               = "~> 4.0"
      configuration_aliases = [google.compute, google.vpc]
    }

    google-beta = {
      version               = "~> 4.0"
      source                = "hashicorp/google-beta"
      configuration_aliases = [google-beta.compute-beta]
    }

    random = {
      version = "~> 3.0"
    }
  }
}

# Shared VPC Permissions
data "google_project" "service_project" {
  provider = google.compute
}

data "google_project" "host_project" {
  provider = google.vpc
}

locals {
  project_number = data.google_project.service_project.number
  project_id     = data.google_project.service_project.project_id
}

resource "google_service_account" "default" {
  account_id   = "${var.cluster_name}-sa"
  display_name = "${var.cluster_name} Service Account"
}

data "google_container_engine_versions" "asiasoutheast2" {
  provider = google-beta.compute-beta

  location       = var.google_region
  version_prefix = "${var.min_master_version}."
}

#tfsec:ignore:google-gke-enforce-pod-security-policy
#tfsec:ignore:google-gke-metadata-endpoints-disabled (legacy metadata disabled by default since 1.12 https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/container_cluster#nested_workload_identity_config)
resource "google_container_cluster" "primary" {
  provider = google-beta.compute-beta

  #checkov:skip=CKV_GCP_67:Legacy metadata disabled by default since 1.12 https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/container_cluster#nested_workload_identity_config
  #checkov:skip=CKV_GCP_24:PodSecurityPolicy is deprecated (https://cloud.google.com/kubernetes-engine/docs/how-to/pod-security-policies)
  #checkov:skip=CKV_GCP_18:Public access currently needed for development purposes (see https://linear.app/honestbank/issue/DEVOP-746/fix-ckv-gcp-18-for-terraform-gcp-gke)
  name     = var.cluster_name
  location = var.google_region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  enable_shielded_nodes    = true
  min_master_version       = data.google_container_engine_versions.asiasoutheast2.latest_master_version

  enable_binary_authorization = true
  dynamic "authenticator_groups_config" {
    for_each = length(var.gke_authenticator_groups_config_domain) > 0 ? [var.gke_authenticator_groups_config_domain] : []
    content {
      security_group = "gke-security-groups@${var.gke_authenticator_groups_config_domain}"
    }
  }

  master_auth { #tfsec:ignore:google-gke-no-legacy-authentication - False positive?
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.master_authorized_networks_config_cidr_block
    }
  }

  workload_identity_config {
    workload_pool = "${data.google_project.service_project.project_id}.svc.id.goog"
  }

  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = var.machine_type

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    tags = [
      local.gke_node_pool_tag
    ]
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }

    network_policy_config {
      disabled = !var.enable_network_policy
    }

    istio_config {
      disabled = true
    }
  }

  # Autoscaling/Node Auto-Provisioning
  # Disable Node Auto-Provisioning and scale at the Node Pool level
  cluster_autoscaling {
    enabled = false
  }

  # Intranode visibility configures networking on each node in the cluster so that traffic sent from one Pod to another
  # Pod is processed by the cluster's Virtual Private Cloud (VPC) network, even if the Pods are on the same node.
  # https://cloud.google.com/kubernetes-engine/docs/how-to/intranode-visibility
  enable_intranode_visibility = true

  network = var.shared_vpc_self_link
  # Setting VPC_NAME requires the ip_allocation_policy block
  networking_mode = "VPC_NATIVE"
  subnetwork      = var.subnetwork_self_link
  ip_allocation_policy {
    # Secondary ranges can be built by https://github.com/honestbank/terraform-gcp-vpc
    cluster_secondary_range_name  = var.pods_ip_range_name
    services_secondary_range_name = var.services_ip_range_name
  }

  network_policy {
    enabled = var.enable_network_policy
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    master_global_access_config {
      enabled = false
    }
  }

  release_channel {
    channel = "RAPID"
  }

  # must only contain lowercase letters ([a-z]), numeric characters ([0-9]), underscores (_) and dashes (-), and must start with a letter. International characters are allowed.
  resource_labels = {
    "terraform" = "true"
  }

  lifecycle {
    ignore_changes = [
      node_pool,
      node_config,
    ]
  }
}

resource "random_id" "node_pool_tag" {
  byte_length = 4
}

locals {
  gke_node_pool_tag = "gke-primary-node-pool-${random_id.node_pool_tag.hex}"
}

resource "google_container_node_pool" "primary_node_pool" {
  provider = google-beta.compute-beta

  name     = "primary"
  location = var.google_region

  version = data.google_container_engine_versions.asiasoutheast2.latest_node_version

  node_locations = [
    "${var.google_region}-a",
    "${var.google_region}-b",
    "${var.google_region}-c",
  ]
  cluster    = google_container_cluster.primary.name
  node_count = var.minimum_node_count

  autoscaling {
    max_node_count = var.maximum_node_count
    min_node_count = var.minimum_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    // TODO: Check format and add tags
    tags = [
      local.gke_node_pool_tag
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# We use this data provider to expose an access token for communicating with the GKE cluster.
data "google_client_config" "default" {
  provider = google-beta.compute-beta
}

data "google_container_cluster" "current_cluster" {
  provider = google-beta.compute-beta

  name     = google_container_cluster.primary.name
  location = google_container_cluster.primary.location
}

resource "google_compute_router" "router" {
  provider = google.vpc
  name     = "${var.cluster_name}-router"
  region   = var.google_region
  network  = var.shared_vpc_id
}

resource "google_compute_router_nat" "nat" {
  provider                           = google.vpc
  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.google_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  lifecycle {
    ignore_changes = [
      drain_nat_ips,
      nat_ips,
    ]
  }
}
