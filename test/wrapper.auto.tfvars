### Use this file to override variables in the template
### Examples are provided below:

### Full GCP project name
google_project                 = "test-terraform-project-01"
shared_vpc_host_google_project = "test-terraform-project-01"

### GCP region
google_region = "asia-southeast2"

### Environment - can be ["test", "dev", "qa", "preprod", "prod"]
stage = "test"

### Cluster configuration values
machine_type       = "e2-standard-4"
minimum_node_count = 1
maximum_node_count = 3
min_master_version = "1.22"
initial_node_count = 1
node_count         = 1

gke_authenticator_groups_config_domain       = "honestbank.com"
enable_network_policy                        = true
master_ipv4_cidr_block                       = "10.40.0.0/28"
master_authorized_networks_config_cidr_block = "0.0.0.0/0"
