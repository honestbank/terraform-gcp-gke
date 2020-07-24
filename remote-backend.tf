terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "honestbank"

    workspaces {
      name = "terraform-gcp-gke-template"
    }
  }
}

//variable "google_credentials" {
//  description = "GCP credentials with write access to the required project"
//}

module gke {
  source = "./gcp-gke"

  google_credentials = var.google_credentials
  environment        = var.environment
  cluster_purpose    = var.cluster_purpose
  cluster_number     = var.cluster_number
}
