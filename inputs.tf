variable "create_gcp_router" {
  type        = bool
  description = "Set to `true` to create a router in the VPC network."
}

variable "create_gcp_nat" {
  type        = bool
  description = "Set to `true` to create an Internet NAT for ALL_SUBNETWORKS_ALL_IP_RANGES in the VPC network."
}

variable "create_public_https_firewall_rule" {
  type        = bool
  description = "Set to `true` to create a firewall rule allowing 0.0.0.0/0:443 on TCP to all worker nodes."
}

variable "enable_network_policy" {
  type        = bool
  description = "This value is passed to network_policy.enabled and the negative is passed to addons_config.network_policy_config.disabled. This might conflict with Workload Identity - make sure to read https://cloud.google.com/kubernetes-engine/docs/how-to/network-policy#limitations_and_requirements."
}

variable "gke_authenticator_groups_config_domain" {
  type        = string
  description = "Domain to append to `gke-security-groups` to pass to authenticator_groups_config so members of that Google Group can authenticate to the cluster. Pass an empty string to disable. Domain passed here should be in the format of TLD.EXTENSION."
}

variable "google_project" {
  type        = string
  description = "The GCP project to use for this run"
}

variable "google_credentials" {
  type        = string
  description = "Contents of a JSON keyfile of an account with write access to the project"
}

variable "google_region" {
  type        = string
  description = "GCP region used to create all resources in this run"
}

variable "initial_node_count" {
  type        = number
  description = "Initial node count, per-zone for regional clusters."
}

variable "kubernetes_version" {
  description = "The Kubernetes version to install on the master and node pool - must be a valid version from the specified `var.release_channel`"
  type        = string
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of authorized networks to access the control plane. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)."
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The IP range to set for master nodes, passed to master_ipv4_cidr_block - /28 required by Google."
}

variable "maximum_node_count" {
  type        = string
  description = "Maximum nodes for the node pool. This is the total nodes so for regional deployments it is the total nodes across all zones."
}

variable "machine_type" {
  type        = string
  description = "Machine types to use for the node pool."
}

variable "minimum_node_count" {
  type        = string
  description = "Minimum nodes for the node pool. This is the total nodes so for regional deployments it is the total nodes across all zones."
}

variable "nat_ip_address_self_links" {
  type        = list(string)
  description = "List of IP address self links to use for NAT"
  default     = []
}

variable "pods_ip_range_cidr" {
  type        = string
  description = "CIDR of the secondary IP range used for Kubernetes Pods."
}

variable "pods_ip_range_name" {
  type        = string
  description = "Name of the secondary IP range used for Kubernetes Pods."
}

variable "release_channel" {
  type        = string
  description = "(Beta) The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `REGULAR`."
  default     = "RAPID"
}

variable "services_ip_range_cidr" {
  type        = string
  description = "CIDR of the secondary IP range used for Kubernetes Services."
}

variable "services_ip_range_name" {
  type        = string
  description = "Name of the secondary IP range used for Kubernetes Services."
}

variable "shared_vpc_host_google_credentials" {
  type        = string
  description = "Service Account with access to shared_vpc_host_google_project networks"
}

variable "shared_vpc_host_google_project" {
  type        = string
  description = "The GCP project that hosts the shared VPC to place resources into"
}

variable "shared_vpc_id" {
  type        = string
  description = "The id of the shared VPC."
}

variable "shared_vpc_self_link" {
  type        = string
  description = "self_link of the shared VPC to place the GKE cluster in."
}

variable "stage" {
  type        = string
  description = "Stage: [test, dev, prod...] used as prefix for all resources."
  default     = "test"
}

variable "subnetwork_self_link" {
  type        = string
  description = "self_link of the google_compute_subnetwork to place the GKE cluster in."
}
