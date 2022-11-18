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
maximum_node_count = 3
initial_node_count = 1

gke_authenticator_groups_config_domain       = "honestbank.com"
enable_network_policy                        = true
master_ipv4_cidr_block                       = "10.40.0.0/28"
master_authorized_networks_config_cidr_block = "0.0.0.0/0"
release_channel                              = "REGULAR"
kubernetes_version                           = "1.24.3-gke.2100"
node_pools = [
  {
    name               = "primary",
    machine_type       = "e2-standard-4"
    minimum_node_count = 1
    maximum_node_count = 3
    tags               = ["terratest"]
  },
]
