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
minimum_node_count = 3
maximum_node_count = 9
min_master_version = "1.21"
initial_node_count = 1

pods_ip_range_cidr                           = "10.20.0.0/16"
pods_ip_range_name                           = "honestcard-compute-pods-subnet"
services_ip_range_cidr                       = "10.30.0.0/16"
services_ip_range_name                       = "honestcard-compute-services-subnet"
shared_vpc_self_link                         = "https://www.googleapis.com/compute/v1/projects/test-terraform-project-01/global/networks/vpc"
shared_vpc_id                                = "projects/test-terraform-project-01/global/networks/vpc"
subnetwork_self_link                         = "https://www.googleapis.com/compute/v1/projects/test-terraform-project-01/regions/asia-southeast2/subnetworks/honestcard-compute-primary-subnet"
gke_authenticator_groups_config_domain       = "honestbank.com"
enable_network_policy                        = true
master_ipv4_cidr_block                       = "10.40.0.0/28"
master_authorized_networks_config_cidr_block = "0.0.0.0/0"
