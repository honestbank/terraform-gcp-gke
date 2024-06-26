resource "random_id" "run_id" {
  byte_length = 4
}

module "gke" {
  providers = {
    google.compute           = google
    google.vpc               = google.vpc
    google-beta.compute-beta = google-beta.compute-beta
  }

  source = "./modules/gcp-gke"

  stage        = var.stage
  cluster_name = "gke-${random_id.run_id.hex}"

  kubernetes_version = var.kubernetes_version
  release_channel    = var.release_channel

  create_gcp_nat                    = var.create_gcp_nat
  create_gcp_router                 = var.create_gcp_router
  create_public_https_firewall_rule = var.create_public_https_firewall_rule
  enable_network_policy             = var.enable_network_policy
  nat_ip_address_self_links         = var.nat_ip_address_self_links

  gke_authenticator_groups_config_domain = var.gke_authenticator_groups_config_domain
  google_project                         = var.google_project
  google_region                          = var.google_region
  machine_type                           = var.machine_type
  master_authorized_networks             = var.master_authorized_networks

  master_ipv4_cidr_block = var.master_ipv4_cidr_block

  initial_node_count = var.initial_node_count
  minimum_node_count = var.minimum_node_count
  maximum_node_count = var.maximum_node_count

  shared_vpc_id                  = var.shared_vpc_id
  shared_vpc_host_google_project = var.shared_vpc_host_google_project
  shared_vpc_self_link           = var.shared_vpc_self_link
  subnetwork_self_link           = var.subnetwork_self_link
  pods_ip_range_name             = var.pods_ip_range_name
  services_ip_range_name         = var.services_ip_range_name
  enable_cost_allocation_feature = var.enable_cost_allocation_feature
  enable_l4_ilb_subsetting       = var.enable_l4_ilb_subsetting

  skip_create_built_in_node_pool = true
  additional_node_pools = [
    {
      name               = "primary"
      machine_type       = var.machine_type
      minimum_node_count = var.minimum_node_count
      maximum_node_count = var.maximum_node_count
      enable_secure_boot = true
      taints = [{
        key    = "terratest"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
      tags  = ["terratest"]
      zones = ["asia-southeast2-a", "asia-southeast2-b", "asia-southeast2-c"]
    },
  ]
}
