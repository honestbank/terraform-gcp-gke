provider "google" {
  # Use 'export GCLOUD_CREDENTIALS="PATH_TO_KEYFILE_JSON"' instead of
  # committing a keyfile to versioning
  # credentials = file("PATH_TO_KEYFILE_JSON")
  project     = var.project
  region      = var.region
  credentials = var.google_credentials

  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
  version = "~> 3.29.0"
}

# provider "google-beta" {
#   # Use 'export GCLOUD_CREDENTIALS="PATH_TO_KEYFILE_JSON"' instead of
#   # committing a keyfile to versioning
#   # credentials = file("PATH_TO_KEYFILE_JSON")
#   project = var.project
#   region  = var.region

#   scopes = [
#     # Default scopes
#     "https://www.googleapis.com/auth/compute",
#     "https://www.googleapis.com/auth/cloud-platform",
#     "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
#     "https://www.googleapis.com/auth/devstorage.full_control",

#     # Required for google_client_openid_userinfo
#     "https://www.googleapis.com/auth/userinfo.email",
#   ]
# }

terraform {
  required_version = "~> 0.12.28"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

provider "kubernetes" {
  version = "~> 1.11.0"
}

provider "helm" {
  # Use provider with Helm 3.x support
  version = "~> 1.2.3"
}

provider "template" {
  version = "~> 2.1"
}

module "primary-cluster" {
  # google-beta
  # source                     = "./modules/terraform-google-kubernetes-engine/modules/beta-public-cluster-update-variant"
  source                     = "./modules/terraform-google-kubernetes-engine/"
  project_id                 = var.project
  name                       = local.cluster_name
  region                     = var.region
  zones                      = var.zones
  network                    = module.primary-cluster-networking.network_name
  subnetwork                 = module.primary-cluster-networking.subnets_names[0]
  ip_range_pods              = module.primary-cluster-networking.subnets_secondary_ranges[0][0]["range_name"]
  ip_range_services          = module.primary-cluster-networking.subnets_secondary_ranges[0][1]["range_name"]
  http_load_balancing        = false
  horizontal_pod_autoscaling = false
  network_policy             = true //Required for GKE-installed Istio
  # service_account            = var.cluster_service_account_name
  create_service_account = true

  # google-beta provider options
  # release_channel = var.release_channel

  node_pools = [
    {
      name               = local.primary_node_pool_name
      machine_type       = var.machine_type
      min_count          = var.minimum_node_count
      max_count          = var.maximum_node_count
      local_ssd_count    = 1
      disk_size_gb       = 200
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = module.primary-cluster.service_account
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

module "primary-cluster-networking" {
  source       = "./modules/terraform-google-network"
  project_id   = var.project
  network_name = local.network_name
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = local.primary_subnet_name
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${local.primary_subnet_name}" = [
      {
        range_name = local.pods_ip_range_name
        # ip_cidr_range = "192.168.0.0/18"
        ip_cidr_range = "10.11.0.0/16"
      },
      {
        range_name = local.services_ip_range_name
        # ip_cidr_range = "192.168.64.0/18"
        ip_cidr_range = "10.12.0.0/16"
      },
    ]
  }
}

module "primary-cluster-auth" {
  source = "./modules/terraform-google-kubernetes-engine/modules/auth"

  project_id   = var.project
  cluster_name = local.cluster_name
  location     = module.primary-cluster.location
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE KUBECTL AND RBAC ROLE PERMISSIONS
# ---------------------------------------------------------------------------------------------------------------------

# We use this data provider to expose an access token for communicating with the GKE cluster.
data "google_client_config" "client" {}

# Use this datasource to access the Terraform account's email for Kubernetes permissions.
data "google_client_openid_userinfo" "terraform_user" {}

# configure kubectl with the credentials of the GKE cluster
resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${module.primary-cluster.name} --region ${var.region} --project ${var.project}"

    # Use environment variables to allow custom kubectl config paths
    # environment = {
    #   KUBECONFIG = var.kubectl_config_path != "" ? var.kubectl_config_path : ""
    # }
  }

  depends_on = [module.primary-cluster]
}

# resource "kubernetes_cluster_role_binding" "user" {
#   metadata {
#     name = "admin-user"
#   }

#   role_ref {
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#     api_group = "rbac.authorization.k8s.io"
#   }

#   subject {
#     kind      = "User"
#     name      = data.google_client_openid_userinfo.terraform_user.email
#     api_group = "rbac.authorization.k8s.io"
#   }

#   subject {
#     kind      = "Group"
#     name      = "system:masters"
#     api_group = "rbac.authorization.k8s.io"
#   }

#   depends_on = [null_resource.configure_kubectl]
# }

# Install Istio Operator using istioctl
resource "null_resource" "install_istio_operator" {
  provisioner "local-exec" {
    command = <<EOH
curl -sL https://istio.io/downloadIstioctl | sh -
export PATH=$PATH:$HOME/.istioctl/bin
istioctl operator init
kubectl label namespace default istio-injection=enabled
EOH
  }

  depends_on = [null_resource.configure_kubectl]
}

# Set up Kiali credentials
resource "null_resource" "set_kiali_credentials" {
  provisioner "local-exec" {
    command = <<EOH
kubectl create ns istio-system
KIALI_USERNAME=$(printf "${var.kiali_username}" | base64)
echo "Kiali Username (base64): "$KIALI_USERNAME
KIALI_PASSPHRASE=$(printf "${var.kiali_passphrase}" | base64)
echo "Kiali Passphrase (base64): "$KIALI_PASSPHRASE
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF
EOH
  }

  depends_on = [null_resource.install_istio_operator]
}

# Install IstioOperator resource manifest to trigger mesh installation
resource "null_resource" "install_IstioOperator_manifest" {
  provisioner "local-exec" {
    command = <<EOH
cat <<EOF | kubectl apply -f -
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: honestbank-istio-mesh
spec:
  profile: default
  addonComponents:
    grafana:
      enabled: true
    kiali:
      enabled: true
EOF
EOH
  }

  depends_on = [null_resource.install_istio_operator]
}
