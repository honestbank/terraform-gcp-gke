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
# maximum_node_count           = 5 // Maximum 5 nodes per zone = 15 nodes
# cluster_service_account_name = "test-terraform-service-acc-636@test-terraform-project-01.iam.gserviceaccount.com"
machine_type       = "e2-standard-4"
minimum_node_count = 1
maximum_node_count = 3
min_master_version = "1.22"
initial_node_count = 1

#pods_ip_range_name              = "honestcard-compute-pods-subnet"
#services_ip_range_name          = "honestcard-compute-services-subnet"
#shared_vpc_self_link            = "https://www.googleapis.com/compute/v1/projects/test-terraform-project-01/global/networks/vpc"
#shared_vpc_id                   = "projects/test-terraform-project-01/global/networks/vpc"
#subnetwork_self_link            = "https://www.googleapis.com/compute/v1/projects/test-terraform-project-01/regions/asia-southeast2/subnetworks/honestcard-compute-primary-subnet"
gke_authenticator_groups_config = "gke-security-groups@honestbank.com"
