provider "google" {
  project     = var.google_project
  region      = var.google_region
  credentials = var.google_credentials

  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
  version = "<= 4.0.0"
}

provider "google" {
  alias       = "vpc"
  project     = var.shared_vpc_host_google_project
  region      = var.google_region
  credentials = var.shared_vpc_host_google_credentials
}

terraform {
  required_version = ">= 0.13.1"
}

provider "null" {
  version = "<= 3.0"
}

provider "random" {
  version = "<= 3.0"
}

provider "template" {
  version = "<= 3.0"
}

resource "random_id" "run_id" {
  byte_length = 4
}

# Shared VPC Permissions
data "google_project" "service_project" {
// Use default google provider
}

data "google_project" "host_project" {
  provider = google.vpc
}

locals {
  project_number = data.google_project.service_project.number
  project_id     = data.google_project.service_project.project_id
}

resource "google_project_iam_binding" "compute-network-user" {
  provider = google.vpc
  project = data.google_project.host_project.project_id
  role    = "roles/compute.networkUser"

  members = [
    "serviceAccount:${format("service-%s@container-engine-robot.iam.gserviceaccount.com", local.project_number)}",
    "serviceAccount:${format("%s@cloudservices.gserviceaccount.com", local.project_number)}",
  ]
}

# GKE Cluster Config
module "primary-cluster" {
  source = "./modules/terraform-google-kubernetes-engine"

  project_id                 = var.google_project
  name                       = local.cluster_name
  region                     = var.google_region
  zones                      = var.zones
  network                    = local.network_name
  network_project_id         = var.shared_vpc_host_google_project
  subnetwork                 = local.primary_subnet_name
  ip_range_pods              = local.pods_ip_range_name
  ip_range_services          = local.services_ip_range_name
  http_load_balancing        = false
  horizontal_pod_autoscaling = false
  create_service_account     = true
//  remove_default_node_pool   = true

  # Required for GKE-installed Istio
  network_policy = true

  node_pools = [
    {
      name            = "pool-01"
      machine_type    = var.machine_type
      min_count       = var.minimum_node_count
      max_count       = var.maximum_node_count
      node_count      = 1
      local_ssd_count = 1
      disk_size_gb    = 200
      disk_type       = "pd-standard"
      image_type      = "COS"
      auto_repair     = true
      auto_upgrade    = true
      preemptible     = false
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/logging.write",
    ]
  }
}

# We use this data provider to expose an access token for communicating with the GKE cluster.
data "google_client_config" "default" {}

data "google_container_cluster" "current_cluster" {
  name     = module.primary-cluster.name
  location = module.primary-cluster.location
}

# Bootstrap to install service mesh, logging, etc
module bootstrap {
  source = "./modules/bootstrap"

  google_credentials = var.google_credentials
  google_project     = var.google_project

  cluster_name           = module.primary-cluster.name
  cluster_location       = module.primary-cluster.location
  cluster_host           = "https://${module.primary-cluster.endpoint}"
  cluster_token          = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.primary-cluster.ca_certificate)

  kiali_username   = var.kiali_username
  kiali_passphrase = var.kiali_passphrase
}
