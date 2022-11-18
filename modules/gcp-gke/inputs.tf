variable "cluster_name" {
  type        = string
  description = "The name to set on the GKE cluster."
}

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
  description = "This value is passed to network_policy.enabled and the negative is passed to addons_config.network_policy_config.disabled."
}

variable "gke_authenticator_groups_config_domain" {
  type        = string
  description = "Domain to append to `gke-security-groups` to pass to authenticator_groups_config so members of that Google Group can authenticate to the cluster. Pass an empty string to disable. Domain passed here should be in the format of TLD.EXTENSION."
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

variable "kubernetes_version" {
  description = "The Kubernetes version to install on the master and node pool - must be a valid version from the specified `var.release_channel`"
  type        = string
}

variable "master_authorized_networks_config_cidr_block" {
  description = "The IP range allowed to access the control plane, passed to the master_authorized_network_config.cidr_blocks.cidr_block field."
}

variable "master_ipv4_cidr_block" {
  description = "The IP range to set for master nodes, passed to master_ipv4_cidr_block - /28 required by Google."
}

variable "pods_ip_range_name" {
  type        = string
  description = "Name of the secondary IP range used for Kubernetes Pods."
}

variable "subnetwork_self_link" {
  type        = string
  description = "self_link of the google_compute_subnetwork to place the GKE cluster in."
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
}

variable "shared_vpc_host_google_project" {
  description = "The GCP project that hosts the VPC to place the GKE cluster in - can be an in-project VPC or a shared VPC. In the case of a shared VPC, the Service Account used to run this module must have permissions to create a Router/NAT in the VPC host project."
}

variable "shared_vpc_id" {
  type        = string
  description = "The id of the shared VPC."
}

variable "stage" {
  description = "Stage: [test, dev, prod...] used as prefix for all resources."
  default     = "test"
}

variable "autoscaling_location_policy" {
  type        = string
  description = <<EOF
    (Optional) Location policy specifies the algorithm used when scaling-up the node pool. \ "BALANCED" - Is a best effort policy that aims to balance the sizes of available zones. \ "ANY" - Instructs the cluster autoscaler to prioritize utilization of unused reservations, and reduce preemption risk for Spot VMs.
    EOF
  default     = "BALANCED"

  validation {
    condition     = contains(["BALANCED", "ANY"], var.autoscaling_location_policy)
    error_message = "autoscaling_location_policy must be either 'BALANCED' or 'ANY'"
  }
}

variable "node_pools" {
  type = list(object({
    name               = string
    machine_type       = string
    minimum_node_count = string
    maximum_node_count = string
    tags               = list(string)
  }))
  nullable = false
}
