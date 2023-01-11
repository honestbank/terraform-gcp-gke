resource "random_id" "run_id" {
  byte_length = 4
}

module "gke" {
  source = "../../modules/gcp-gke"

  stage        = var.stage
  cluster_name = var.cluster_name

  kubernetes_version_prefix = var.kubernetes_version_prefix
  release_channel           = var.release_channel

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

  shared_vpc_id                  = module.vpc.network_id
  shared_vpc_host_google_project = var.shared_vpc_host_google_project
  shared_vpc_self_link           = module.vpc.shared_vpc_self_link
  subnetwork_self_link           = module.vpc.primary_subnet_self_link
  pods_ip_range_name             = module.vpc.pods_subnet_name
  services_ip_range_name         = module.vpc.services_subnet_name

  skip_create_built_in_node_pool = true
  additional_node_pools = [
    {
      name               = "primary"
      machine_type       = var.machine_type
      minimum_node_count = var.minimum_node_count
      maximum_node_count = var.maximum_node_count
      tags               = ["terratest"]
    },
  ]

}
