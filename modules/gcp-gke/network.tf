// tfsec ignore rule because it triggers a false-positive
data "google_container_cluster" "primary" {
  provider = google.compute

  name     = var.cluster_name
  location = var.google_region

  depends_on = [
    google_container_cluster.primary,
    module.node_pools,
  ]
}

locals {
  ip_addresses = ["a", "b", "c", "d"]
}

resource "google_compute_global_address" "external_nat_ips" {
  for_each = toset(local.ip_addresses)

  name         = "nat-ip-${each.key}"
  address_type = "EXTERNAL"
  purpose      = "GLOBAL"
}

resource "google_compute_firewall" "gke_private_cluster_master_to_nodepool" {
  count = length(var.allow_k8s_control_plane) > 0 ? 1 : 0

  provider = google.vpc

  name      = "honest-${var.cluster_name}-allow-master-to-nodepool"
  network   = var.shared_vpc_id
  disabled  = false
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = var.allow_k8s_control_plane
  }

  source_ranges = [var.master_ipv4_cidr_block]
  target_tags   = local.all_primary_node_pool_tags

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      source_service_accounts,
      target_service_accounts,
    ]
  }
}

resource "google_compute_router" "router" {
  count = var.create_gcp_router ? 1 : 0

  provider = google.vpc

  name    = "${var.cluster_name}-router"
  region  = var.google_region
  network = var.shared_vpc_id
}

resource "google_compute_router_nat" "nat" {
  count             = var.create_gcp_nat ? 1 : 0
  external_ip_count = length(local.ip_addresses) > 0 ? 1 : 0

  provider = google.vpc

  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.router[0].name
  region                             = var.google_region
  nat_ip_allocate_option             = length(local.ip_addresses) > 0 ? "MANUAL_ONLY" : "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ips                            = length(local.ip_addresses) > 0 ? tolist(values(google_compute_global_address.external_nat_ips)) : []

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

resource "google_compute_firewall" "gke_private_cluster_public_https_firewall_rule" { #tfsec:ignore:google-compute-no-public-ingress
  count = var.create_public_https_firewall_rule ? 1 : 0

  provider = google.vpc

  name    = "honest-${var.cluster_name}-allow-https"
  network = var.shared_vpc_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.gke_node_pool_tag]
}
