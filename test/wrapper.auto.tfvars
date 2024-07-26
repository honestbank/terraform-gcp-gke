### Use this file to override variables in the template
### Examples are provided below:

create_gcp_router                 = true
create_gcp_nat                    = true
create_public_https_firewall_rule = true

### Full GCP project IDs
google_project                 = "compute-df9f"
shared_vpc_host_google_project = "tf-shared-vpc-host-78a3"

### GCP region
google_region = "asia-southeast2"

### Environment - can be ["test", "dev", "qa", "preprod", "prod"]
stage = "test"

### Cluster configuration values
machine_type       = "e2-standard-4"
minimum_node_count = 1
maximum_node_count = 3
initial_node_count = 1

gke_authenticator_groups_config_domain = "honestbank.com"
enable_network_policy                  = true
master_ipv4_cidr_block                 = "10.40.0.0/28"

master_authorized_networks = [
  {
    cidr_block   = "0.0.0.0/0"
    display_name = "Access from Everywhere"
  }
]
maintenance_policy_config = [
  {
    maintenance_start_time = "2023-05-19T06:00:00Z"
    maintenance_end_time   = "2023-05-19T10:00:00Z"
    maintenance_recurrence = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH"
  }
]
enable_cost_allocation_feature = true
enable_l4_ilb_subsetting       = true
deletion_protection            = false

release_channel    = "RAPID"
kubernetes_version = "1.30.2-gke.1587003"

additional_node_pools = [
  {
    name               = "highmem",
    machine_type       = "e2-highmem-4"
    minimum_node_count = 1
    maximum_node_count = 3
    enable_secure_boot = true
    taints = [{
      key    = "test"
      value  = "true"
      effect = "NO_SCHEDULE"
    }]
    tags  = ["terratest"]
    zones = ["asia-southeast2-a", "asia-southeast2-b", "asia-southeast2-c"]
  }
]
