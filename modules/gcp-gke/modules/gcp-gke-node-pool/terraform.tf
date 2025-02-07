terraform {
  required_version = ">= 1.8, < 2"

  required_providers {
    google-beta = {
      version = ">= 6.0, < 7.0"
      source  = "hashicorp/google-beta"
    }

    random = {
      version = "~> 3.0"
    }
  }
}
