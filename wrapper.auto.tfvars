### Use this file to override variables in the template
### Examples are provided below:

create_gcp_router                 = true
create_gcp_nat                    = true
create_public_https_firewall_rule = true

### Full GCP project name
google_project                 = "compute-df9f"
shared_vpc_host_google_project = "tf-shared-vpc-host-78a3"

### GCP region
google_region = "asia-southeast2"

### Environment - can be ["test", "dev", "qa", "preprod", "prod"]
stage = "test"

### Cluster configuration values
machine_type       = "e2-standard-4"
minimum_node_count = 1
maximum_node_count = 1
initial_node_count = 1

pods_ip_range_cidr                     = "10.20.0.0/16"
pods_ip_range_name                     = "honestcard-compute-pods-subnet"
services_ip_range_cidr                 = "10.30.0.0/16"
services_ip_range_name                 = "honestcard-compute-services-subnet"
shared_vpc_self_link                   = "https://www.googleapis.com/compute/v1/projects/test-terraform-project-01/global/networks/vpc"
shared_vpc_id                          = "projects/test-terraform-project-01/global/networks/vpc"
subnetwork_self_link                   = "https://www.googleapis.com/compute/v1/projects/test-terraform-project-01/regions/asia-southeast2/subnetworks/honestcard-compute-primary-subnet"
gke_authenticator_groups_config_domain = "honestbank.com"
enable_network_policy                  = true
master_ipv4_cidr_block                 = "10.40.0.0/28"

master_authorized_networks = [
  {
    cidr_block   = "0.0.0.0/0"
    display_name = "Access from Everywhere"
  }
]

release_channel    = "REGULAR"
kubernetes_version = "1.24.4-gke.800"
