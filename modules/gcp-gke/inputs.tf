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

variable "allow_k8s_control_plane" {
  type        = list(string)
  description = "List of ports to allow k8s control plane to communicate with the node pool"
  default     = []
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

variable "machine_type" {
  description = "Machine types to use for the node pool."
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of master authorized networks to access the control plane. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)."
  default     = []
}

variable "master_ipv4_cidr_block" {
  description = "The IP range to set for master nodes, passed to master_ipv4_cidr_block - /28 required by Google."
}

variable "maximum_node_count" {
  description = "Maximum nodes for the node pool per-zone."
}

variable "minimum_node_count" {
  description = "Minimum nodes for the node pool per-zone."
}

variable "pods_ip_range_name" {
  type        = string
  description = "Name of the secondary IP range used for Kubernetes Pods."
}

variable "taints" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  description = "A list of Kubernetes taints to apply to nodes. GKE's API can only set this field on cluster creation"
  default     = []

  validation {
    condition     = alltrue([for e in var.taints : contains(["NO_SCHEDULE", "PREFER_NO_SCHEDULE", "PREFER_NO_SCHEDULE"], e.effect)])
    error_message = "Each taint object must have an effect that is one of 'NO_SCHEDULE', 'PREFER_NO_SCHEDULE', or 'NO_EXECUTE'. For more details https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/"
  }
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
  validation {
    condition     = var.enable_auto_upgrade || var.release_channel == "UNSPECIFIED"
    error_message = "The variable 'release_channel' must be set to 'UNSPECIFIED' when 'enable_auto_upgrade' is set to false."
  }
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

variable "additional_node_pools" {
  default     = []
  description = "A list of objects used to configure additional node pools (in addition to the primary one created by this module by default)."
  type = list(object({
    name               = string
    enable_secure_boot = bool
    machine_type       = string
    minimum_node_count = string
    maximum_node_count = string
    spot_nodepool      = bool
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    tags  = list(string)
    zones = list(string)
  }))
  nullable = false
}

variable "skip_create_built_in_node_pool" {
  default     = false
  description = <<EOF
    Skip creation of the primary node pool that is created with the cluster, and instead use only the `additional_node_pools`.
    Note: setting var.skip_create_built_in_node_pool to true requires at least one node pool specified in var.additional_node_pools"
   EOF
  type        = bool
}

variable "enable_dataplane_v2" {
  default     = false
  description = "Enable GKE DataPlane V2 for control plane.Set this value true if need to enable this feature."
}

variable "maintenance_policy_config" {
  type = list(object({
    maintenance_start_time = string
    maintenance_end_time   = string
    maintenance_recurrence = string
  }))
  description = "(OPTIONAL) A list of objects used to configure maintenance policy "
  default     = []
}

variable "nat_ip_address_self_links" {
  type        = list(string)
  description = "List of self links IP addresses to use for NAT"
  default     = []
}

variable "enable_l4_ilb_subsetting" {
  type        = bool
  description = "Enable L4 ILB Subsetting"
  default     = false
}

variable "enable_cost_allocation_feature" {
  type        = bool
  description = "Whether to enable the cost allocation feature."
  default     = false
}

variable "deletion_protection" {
  type        = string
  description = "(Optional) Whether or not to allow Terraform to destroy the cluster. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_taint:~:text=Cloud)%20Learn%20tutorial-,Note,-On%20version%205.0.0"
  default     = true
}

variable "enable_auto_upgrade" {
  type        = bool
  description = "Whether to enable auto upgrades in GKE cluster."
  default     = true
}

variable "notification_config_pub_sub_id" {
  type        = string
  description = "The Pub/Sub topic ID for GKE notification configuration. Must be in the format: projects/{project}/topics/{topic}."
  default     = ""

  validation {
    condition     = can(regex("^projects/[^/]+/topics/[^/]+$", var.notification_config_pub_sub_id)) || var.notification_config_pub_sub_id == ""
    error_message = "The Pub/Sub topic ID must be in the format 'projects/{project}/topics/{topic}' or left empty."
  }
}
