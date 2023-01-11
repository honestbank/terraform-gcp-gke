#google_project = "test-terraform-project-01"
#network_name   = "vpc"
#google_region  = "asia-southeast2"

vpc_routing_mode = "REGIONAL"

vpc_primary_subnet_ip_range_cidr = "10.10.0.0/16"
#vpc_primary_subnet_name          = "primary-subnet"

vpc_secondary_ip_range_pods_cidr = "10.20.0.0/16"
#vpc_secondary_ip_range_pods_name = "pods-subnet"

vpc_secondary_ip_range_services_cidr = "10.30.0.0/16"
#vpc_secondary_ip_range_services_name = "services-subnet"
