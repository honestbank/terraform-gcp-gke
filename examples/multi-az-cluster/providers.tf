# This default provider is needed by Terraform/the Google provider
provider "google" {
  project     = var.google_project
  region      = var.google_region
  credentials = var.google_credentials
}

provider "google" {
  alias       = "compute"
  project     = var.google_project
  region      = var.google_region
  credentials = var.google_credentials
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
