variable "google_credentials" {
  description = "GCP Service Account JSON keyfile contents."
}

variable "shared_vpc_host_google_credentials" {
  description = "Service Account with access to shared_vpc_host_google_project networks"
}

provider "google" {
  project     = var.google_project
  region      = var.google_region
  credentials = var.google_credentials

  #  scopes = [
  #    # Default scopes
  #    "https://www.googleapis.com/auth/compute",
  #    "https://www.googleapis.com/auth/cloud-platform",
  #    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
  #    "https://www.googleapis.com/auth/devstorage.full_control",
  #
  #    # Required for google_client_openid_userinfo
  #    "https://www.googleapis.com/auth/userinfo.email",
  #  ]
}

provider "google" {
  alias       = "compute"
  project     = var.google_project
  region      = var.google_region
  credentials = var.google_credentials

  #  scopes = [
  #    # Default scopes
  #    "https://www.googleapis.com/auth/compute",
  #    "https://www.googleapis.com/auth/cloud-platform",
  #    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
  #    "https://www.googleapis.com/auth/devstorage.full_control",
  #
  #    # Required for google_client_openid_userinfo
  #    "https://www.googleapis.com/auth/userinfo.email",
  #  ]
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
