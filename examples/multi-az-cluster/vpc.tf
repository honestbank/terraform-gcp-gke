#tfsec:ignore:google-compute-enable-vpc-flow-logs
module "vpc" {
  source = "../modules/terraform-gcp-vpc/vpc"

  google_project = var.shared_vpc_host_google_project
  network_name   = var.network_name
  google_region  = var.google_region

  vpc_routing_mode = var.vpc_routing_mode

  vpc_primary_subnet_name          = var.vpc_primary_subnet_name
  vpc_primary_subnet_ip_range_cidr = var.vpc_primary_subnet_ip_range_cidr

  vpc_secondary_ip_range_pods_name = var.vpc_secondary_ip_range_pods_name
  vpc_secondary_ip_range_pods_cidr = var.vpc_secondary_ip_range_pods_cidr

  vpc_secondary_ip_range_services_name = var.vpc_secondary_ip_range_services_name
  vpc_secondary_ip_range_services_cidr = var.vpc_secondary_ip_range_services_cidr
}
