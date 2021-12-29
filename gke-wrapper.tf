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
}

provider "google-beta" {
  alias       = "compute-beta"
  project     = var.google_project
  region      = var.google_region
  credentials = var.google_credentials
}

provider "google" {
  alias       = "vpc"
  project     = var.shared_vpc_host_google_project
  region      = var.google_region
  credentials = var.shared_vpc_host_google_credentials
}

module "gke" {

  providers = {
    google.compute           = google
    google.vpc               = google.vpc
    google-beta.compute-beta = google-beta.compute-beta
  }

  source = "./gcp-gke"

  google_project     = var.google_project
  google_region      = var.google_region
  google_credentials = var.google_credentials

  shared_vpc_host_google_project     = var.shared_vpc_host_google_project
  shared_vpc_host_google_credentials = var.shared_vpc_host_google_credentials

  stage           = var.stage
  cluster_purpose = var.cluster_purpose
  cluster_number  = var.cluster_number

  machine_type       = var.machine_type
  minimum_node_count = var.minimum_node_count
  maximum_node_count = var.maximum_node_count
  initial_node_count = var.initial_node_count
}
