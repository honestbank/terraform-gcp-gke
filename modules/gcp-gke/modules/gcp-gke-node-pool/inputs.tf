variable "name" {
  description = "Name of the node pool. Example: 'primary'"
  type        = string
  nullable    = false
}

variable "cluster_name" {
  description = "Name of the GKE cluster this node pool belongs too."
  type        = string
  nullable    = false
}

variable "google_region" {
  description = "GCP region used to create all resources in this run"
  type        = string
  nullable    = false
}

variable "kubernetes_version" {
  description = "The Kubernetes version to install on the master and node pool - must be a valid version from the specified `var.release_channel`"
  type        = string
  nullable    = false
}

variable "machine_type" {
  description = "Machine types to use for the node pool."
  type        = string
  nullable    = false
}

variable "minimum_node_count" {
  description = "Minimum nodes for the node pool per-zone."
  type        = number
  nullable    = false
}

variable "maximum_node_count" {
  description = "Maximum nodes for the node pool per-zone."
  type        = number
  nullable    = false
  validation {
    condition     = var.maximum_node_count > 0
    error_message = "var.maximum_node_count must be greated than 0, but ${var.maximum_node_count} specified"
  }
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

variable "taints" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  description = "A list of Kubernetes taints to apply to nodes. GKE's API can only set this field on cluster creation"
  default     = []
}

variable "gcp_service_account_email" {
  description = "Email of the GCP Service Account for the Node pool"
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Tags to associate to the node pool. You may add tags related to the firewall rules here."
  type        = list(string)
  default     = []
}
