

variable "project" {
  description = "The GCP project to use for this run"
  default     = "test-terraform-project-01"
}

variable "region" {
  description = "GCP region used to create all resources in this run"
  default     = "asia-southeast2"
}

variable "cluster_name" {
  description = "Name to assign to GKE cluster built in this run."
  default     = "test-gcp-jkt-cluster-00"
}

variable "network_name" {
  description = "Name of the VPC network where GKE cluster will be placed."
  default     = "test-gcp-jkt-cluster-00-network-00"
}

variable "subnet_name" {
  description = "Subnet (aka subnetwork) within the VPC for the GKE cluster."
  default     = "test-gcp-jkt-cluster-00-network-00-subnet-00"
}

variable "ip_range_pods_name" {
  description = "Pods IP subnet name."
  default     = "test-gcp-jkt-cluster-00-pods-ip-range"
}

variable "ip_range_services_name" {
  description = "Services (Kubernetes Service objects) IP range."
  default     = "test-gcp-jkt-cluster-00-services-ip-range"
}

variable "node_pool_name" {
  description = "Name of the main/initial node pool for the GKE cluster."
  default     = "test-gcp-jkt-cluster-00-nodepool-00"
}

variable "cluster_service_account_name" {
  description = "Service account to be used for the GKE cluster and node pools."
  default     = "test-terraform-service-acc-636"
}

variable "zones" {
  default = ["asia-southeast2-a", "asia-southeast2-b", "asia-southeast2-c"]
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
