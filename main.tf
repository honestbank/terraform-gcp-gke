resource "random_id" "run_id" {
  byte_length = 4
}

module "gke" {
  providers = {
    google.compute           = google
    google.vpc               = google.vpc
    google-beta.compute-beta = google-beta.compute-beta
  }

  source = "./gcp-gke"

  stage        = var.stage
  cluster_name = "gke-${random_id.run_id.hex}"

  min_master_version = var.min_master_version
  release_channel    = "RAPID"

  create_gcp_nat                    = var.create_gcp_nat
  create_gcp_router                 = var.create_gcp_router
  create_public_https_firewall_rule = var.create_public_https_firewall_rule
  enable_network_policy             = var.enable_network_policy

  gke_authenticator_groups_config_domain = var.gke_authenticator_groups_config_domain
  google_project                         = var.google_project
  google_region                          = var.google_region
  machine_type                           = var.machine_type

  master_authorized_networks_config_cidr_block = var.master_authorized_networks_config_cidr_block

  master_ipv4_cidr_block = var.master_ipv4_cidr_block

  initial_node_count = var.initial_node_count
  minimum_node_count = var.minimum_node_count
  maximum_node_count = var.maximum_node_count
  node_count         = var.node_count

  shared_vpc_id                  = var.shared_vpc_id
  shared_vpc_host_google_project = var.shared_vpc_host_google_project
  shared_vpc_self_link           = var.shared_vpc_self_link
  subnetwork_self_link           = var.subnetwork_self_link
  pods_ip_range_name             = var.pods_ip_range_name
  services_ip_range_name         = var.services_ip_range_name
}
