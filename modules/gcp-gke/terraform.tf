terraform {
  required_version = ">= 1.2.9"

  required_providers {
    google = {
      version               = ">= 4.0"
      configuration_aliases = [google.compute, google.vpc]
    }

    google-beta = {
      version = ">= 4.0"
      source  = "hashicorp/google-beta"
    }

    random = {
      version = "~> 3.0"
    }
  }
}
