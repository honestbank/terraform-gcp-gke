variable "shared_vpc_host_google_credentials" {
  description = "Service Account with access to shared_vpc_host_google_project networks"
}

provider "google" {
  # Use 'export GCLOUD_CREDENTIALS="PATH_TO_KEYFILE_JSON"' instead of
  # committing a keyfile to versioning

  credentials = var.shared_vpc_host_google_credentials
  project     = var.google_project
  region      = var.google_region
}

provider "google-beta" {
  # Use 'export GCLOUD_CREDENTIALS="PATH_TO_KEYFILE_JSON"' instead of
  # committing a keyfile to versioning

  credentials = var.shared_vpc_host_google_credentials
  project     = var.google_project
  region      = var.google_region
}

## THIS SHOULD NOT BE USED. DO NOT UNCOMMENT.
## This is too much logic in test code. If this kind of resource is needed,
## it should be either:
## * Provisioned by the main module.
## * Provisioned by a module that this test depends on/uses.
## * Documented in code and executed manually to bootstrap a set of test/lab GCP projects.
##
## A host project provides network resources to associated service projects.
#resource "google_compute_shared_vpc_host_project" "host" {
#  provider = google-beta
#  project = var.google_project
#}
