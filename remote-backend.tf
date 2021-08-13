terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "honestbank"

    workspaces {
      prefix = "terraform-gcp-gke-"
    }
  }

  required_version = ">= 0.13.1"
}
