variable "project" {
  description = "The GCP project to use for this run"
  default     = "test-terraform-project-01"
}

variable "google_credentials" {
  description = "Contents of a JSON keyfile of an account with write access to the project"
}

variable "region" {
  description = "GCP region used to create all resources in this run"
  default     = "asia-southeast2"
}

variable "environment" {
  description = "Environment: [test, dev, prod...] used as prefix for all resources."
  default     = "test"
}

variable "cluster_purpose" {
  description = "Name to assign to GKE cluster built in this run."
  default     = "tf-gke-template"
}

variable "cluster_number" {
  default = 00
}

variable "zones" {
  description = "Zones for the VMs in the cluster. Default is set to Jakarta (all zones)."
  default     = ["asia-southeast2-a", "asia-southeast2-b", "asia-southeast2-c"]
}

variable "release_channel" {
  type        = string
  description = "(Beta) The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `REGULAR`."
  default     = "RAPID"
}

variable "minimum_node_count" {
  default     = 1
  description = "Minimum nodes for the node pool. This is the total nodes so for regional deployments it is the total nodes across all zones."
}

variable "maximum_node_count" {
  default     = 2
  description = "Maximum nodes for the node pool. This is the total nodes so for regional deployments it is the total nodes across all zones."
}

variable "initial_node_count" {
  default     = 1
  description = "Initial node count, per-zone for regional clusters."
}

variable "machine_type" {
  default     = "n1-standard-2"
  description = "Machine types to use for the node pool."
}

variable "kiali_username" {
  default     = "admin"
  description = "Username for Kiali bundled with Istio."
}

variable "kiali_passphrase" {
  default     = "admin"
  description = "Passphrase for Kiali bundled with Istio."
}
