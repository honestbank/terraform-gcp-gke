terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "honestbank"

    workspaces {
      name = "terraform-gcp-gke-template"
    }
  }
}

module gke {
  source = "./gcp-gke"

  project            = var.project
  google_credentials = var.google_credentials
  stage              = var.stage
  cluster_purpose    = var.cluster_purpose
  cluster_number     = var.cluster_number
}
