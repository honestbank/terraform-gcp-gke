// tfsec ignore rule because it triggers a false-positive
data "google_container_cluster" "primary" {
  project = var.google_project

  name     = var.cluster_name
  location = var.google_region

  depends_on = [
    google_container_cluster.primary,
    module.node_pools,
  ]
}

resource "google_compute_firewall" "gke_private_cluster_istio_gatekeeper_rules" { #tfsec:ignore:google-compute-no-public-ingress
  project = var.shared_vpc_host_google_project

  name      = "honest-${var.cluster_name}-allow-istio-gatekeeper"
  network   = var.shared_vpc_id
  disabled  = false
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["15017", "8443"]
  }

  source_ranges = [var.master_ipv4_cidr_block]
  target_tags   = local.all_primary_node_pool_tags

  lifecycle {
    ignore_changes = [
      source_service_accounts,
      target_service_accounts,
    ]
  }
}

resource "google_compute_router" "router" {
  project = var.shared_vpc_host_google_project

  count = var.create_gcp_router ? 1 : 0

  name    = "${var.cluster_name}-router"
  region  = var.google_region
  network = var.shared_vpc_id
}

resource "google_compute_router_nat" "nat" {
  project = var.shared_vpc_host_google_project

  count = var.create_gcp_nat ? 1 : 0

  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.router[0].name
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


resource "google_compute_firewall" "gke_private_cluster_public_https_firewall_rule" { #tfsec:ignore:google-compute-no-public-ingress
  project = var.shared_vpc_host_google_project

  count = var.create_public_https_firewall_rule ? 1 : 0

  name    = "honest-${var.cluster_name}-allow-https"
  network = var.shared_vpc_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.gke_node_pool_tag]
}
