variable "google_credentials" {
  description = "GCP Service Account JSON keyfile contents."
}

variable "shared_vpc_host_google_credentials" {
  description = "Service Account with access to shared_vpc_host_google_project networks"
}

# This default provider is needed by Terraform/the Google provider
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

provider "google-beta" {
  alias       = "vpc-beta"
  project     = var.shared_vpc_host_google_project
  region      = var.google_region
  credentials = var.shared_vpc_host_google_credentials
}

## THIS SHOULD NOT BE USED. DO NOT UNCOMMENT.
## This is too much logic in test code. If this kind of resource is needed,
## it should be either:
## * Provisioned by the main module.
## * Provisioned by a module that this test depends on/uses.
## * Documented in code and executed manually to bootstrap a set of test/lab GCP projects.
##
## A service project gains access to network resources provided by its
## associated host project.
#resource "google_compute_shared_vpc_service_project" "compute_service" {
#  provider = google-beta.vpc-beta
#  host_project    = var.shared_vpc_host_google_project
#  service_project = var.google_project
#
#  lifecycle {
#    prevent_destroy = true
#  }
#}
