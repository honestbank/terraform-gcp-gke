provider "google" {
  # Use 'export GCLOUD_CREDENTIALS="PATH_TO_KEYFILE_JSON"' instead of
  # committing a keyfile to versioning
  # credentials = file("PATH_TO_KEYFILE_JSON")
  project = var.project
  region  = var.region
}



module "primary-cluster" {
  source                     = "./modules/terraform-google-kubernetes-engine"
  project_id                 = var.project
  name                       = var.cluster_name
  region                     = var.region
  zones                      = var.zones
  network                    = module.primary-cluster-networking.network_name
  subnetwork                 = module.primary-cluster-networking.subnets_names[0]
  ip_range_pods              = module.primary-cluster-networking.subnets_secondary_ranges[0][0]["range_name"]
  ip_range_services          = module.primary-cluster-networking.subnets_secondary_ranges[0][1]["range_name"]
  http_load_balancing        = false
  horizontal_pod_autoscaling = false
  network_policy             = false
  service_account            = var.cluster_service_account_name
  # create_service_account     = true
  # release_channel            = var.release_channel

  node_pools = [
    {
      name               = var.node_pool_name
      machine_type       = var.machine_type
      min_count          = var.minimum_node_count
      max_count          = var.maximum_node_count
      local_ssd_count    = 1
      disk_size_gb       = 200
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "test-terraform-service-account@test-terraform-project-01.iam.gserviceaccount.com"
      preemptible        = false
      initial_node_count = var.initial_node_count
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    "${var.node_pool_name}" = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    "${var.node_pool_name}" = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    "${var.node_pool_name}" = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_tags = {
    all = []

    "${var.node_pool_name}" = [
      "default-node-pool",
    ]
  }
}

# To try
# Create VPC manually in https://console.cloud.google.com/networking/networks/list?project=test-terraform-project-01&authuser=0&organizationId=189681559562
# Remove 'routing_mode' - not sure what this does
# Set subnet mode to automatic (automatic subnet creation)
# Copy GCP IP ranges?
module "primary-cluster-networking" {
  source       = "./modules/terraform-google-network"
  project_id   = var.project
  network_name = "${var.cluster_name}-network"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "${var.cluster_name}-subnet"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${var.cluster_name}-subnet" = [
      {
        range_name = "${var.cluster_name}-pods-ip-range"
        # ip_cidr_range = "192.168.0.0/18"
        ip_cidr_range = "10.11.0.0/16"
      },
      {
        range_name = "${var.cluster_name}-services-ip-range"
        # ip_cidr_range = "192.168.64.0/18"
        ip_cidr_range = "10.12.0.0/16"
      },
    ]
  }
}
