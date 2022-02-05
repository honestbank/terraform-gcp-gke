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

  shared_vpc_host_google_project = var.shared_vpc_host_google_project

  stage = var.stage

  release_channel    = "RAPID"
  cluster_name       = "gke-${random_id.run_id.hex}"
  google_project     = var.google_project
  google_region      = var.google_region
  initial_node_count = var.initial_node_count
  machine_type       = var.machine_type
  minimum_node_count = var.minimum_node_count
  maximum_node_count = var.maximum_node_count

  pods_ip_range_name     = var.pods_ip_range_name
  services_ip_range_name = var.services_ip_range_name

  shared_vpc_id        = var.shared_vpc_id
  shared_vpc_self_link = var.shared_vpc_self_link
  subnetwork_self_link = var.subnetwork_self_link

  gke_authenticator_groups_config = var.gke_authenticator_groups_config
  min_master_version              = var.min_master_version
}
