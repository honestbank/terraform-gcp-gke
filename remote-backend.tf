terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "honestbank"

    workspaces {
      name = "terraform-gcp-gke"
    }
  }

  required_version = "~> 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = " ~> 3.6"
    }
  }
}
