variable "cluster_name" {
  description = "Name of the GKE cluster"
}

variable "cluster_location" {
  description = "Location (region/zone) of the GKE cluster"
}

variable "google_credentials" {
  description = "GCP Service Account JSON keyfile contents"
}

variable "google_project" {
  description = "GCP project to use"
}

variable "kiali_username" {
  description = "Username for the Kiali instance installed with Istio"
  default     = "admin"
}

variable "kiali_passphrase" {
  description = "Passphrase for the Kiali instance installed with Istio"
  default     = "admin"
}
