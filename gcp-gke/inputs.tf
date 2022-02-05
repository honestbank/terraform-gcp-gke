variable "gke_authenticator_groups_config" {
  type        = string
  description = "Value to pass to authenticator_groups_config so members of that Google Group can authenticate to the cluster. Pass an empty string to disable."
}

variable "cluster_name" {
  type        = string
  description = "The name to set on the GKE cluster."
}

variable "google_project" {
  description = "The GCP project to use for this run"
}

variable "google_region" {
  description = "GCP region used to create all resources in this run"
}

variable "initial_node_count" {
  description = "Initial node count, per-zone for regional clusters."
}

variable "machine_type" {
  description = "Machine types to use for the node pool."
}

variable "maximum_node_count" {
  description = "Maximum nodes for the node pool per-zone."
}

variable "min_master_version" {
  description = "The min_master_version attribute to pass to the google_container_cluster resource."
}

variable "minimum_node_count" {
  description = "Minimum nodes for the node pool per-zone."
}

variable "pods_ip_range_cidr" {
  type        = string
  description = "CIDR of the secondary IP range used for Kubernetes Pods."
}

variable "pods_ip_range_name" {
  type        = string
  description = "Name of the secondary IP range used for Kubernetes Pods."
}

variable "subnetwork_self_link" {
  type        = string
  description = "self_link of the google_compute_subnetwork to place the GKE cluster in."
}

variable "services_ip_range_cidr" {
  type        = string
  description = "CIDR of the secondary IP range used for Kubernetes Services."
}

variable "services_ip_range_name" {
  type        = string
  description = "Name of the secondary IP range used for Kubernetes Services."
}

variable "shared_vpc_self_link" {
  type        = string
  description = "self_link of the shared VPC to place the GKE cluster in."
}

variable "release_channel" {
  type        = string
  description = "(Beta) The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `REGULAR`."
  default     = "RAPID"
}

variable "shared_vpc_host_google_project" {
  description = "The GCP project that hosts the shared VPC to place resources into"
}

variable "shared_vpc_host_google_credentials" {
  description = "Service Account with access to shared_vpc_host_google_project networks"
}

variable "shared_vpc_id" {
  type        = string
  description = "The id of the shared VPC."
}

variable "stage" {
  description = "Stage: [test, dev, prod...] used as prefix for all resources."
  default     = "test"
}
