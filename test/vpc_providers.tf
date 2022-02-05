variable "google_credentials" {
  description = "GCP Service Account JSON keyfile contents."
}

provider "google" {
  # Use 'export GCLOUD_CREDENTIALS="PATH_TO_KEYFILE_JSON"' instead of
  # committing a keyfile to versioning

  credentials = var.google_credentials
  project     = var.google_project
  region      = var.google_region
}
