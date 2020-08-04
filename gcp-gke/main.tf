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

  # Depends on the primary_cluster_auth module, currently unused in favor of gcloud CLI via shell-exec
  load_config_file = false

  cluster_ca_certificate = module.primary_cluster_auth.cluster_ca_certificate
  host                   = module.primary_cluster_auth.host
  token                  = module.primary_cluster_auth.token

  # host  = "https://${data.google_container_cluster.current_cluster.endpoint}"
  # token = data.google_client_config.provider.access_token
  # cluster_ca_certificate = base64decode(
  #   data.google_container_cluster.current_cluster.master_auth[0].cluster_ca_certificate,
  # )
}

provider "helm" {
  # Use provider with Helm 3.x support
  version = "~> 1.2.3"

  kubernetes {
    host = module.primary_cluster_auth.host

    token                  = module.primary_cluster_auth.token
    cluster_ca_certificate = module.primary_cluster_auth.cluster_ca_certificate
  }
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
  create_service_account     = true

  # Google Container Registry access
  registry_project_id   = var.project
  grant_registry_access = true

  # google-beta provider options
  # release_channel = var.release_channel

  node_pools = [
    {
      name            = "pool-01"
      machine_type    = var.machine_type
      min_count       = var.minimum_node_count
      max_count       = var.maximum_node_count
      node_count      = 1
      local_ssd_count = 1
      disk_size_gb    = 200
      disk_type       = "pd-standard"
      image_type      = "COS"
      auto_repair     = true
      auto_upgrade    = true
      preemptible     = false
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/logging.write",
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

        # Larger range
        # ip_cidr_range = "192.168.0.0/18"

        # Narrower range
        ip_cidr_range = "10.11.0.0/16"
      },
      {
        range_name = local.services_ip_range_name

        # Larger range
        # ip_cidr_range = "192.168.64.0/18"

        # Narrower range
        ip_cidr_range = "10.12.0.0/16"
      },
    ]
  }
}

### Use this to get kubeconfig data to connect to the cluster
### Currently using the shell-exec provisioner and gcloud CLI instead
# module "primary-cluster-auth" {
module "primary_cluster_auth" {
  source = "./modules/terraform-google-kubernetes-engine/modules/auth"

  project_id   = var.project
  cluster_name = module.primary-cluster.name
  location     = module.primary-cluster.location
}

# We use this data provider to expose an access token for communicating with the GKE cluster.
data "google_client_config" "client" {}

# Use this datasource to access the Terraform account's email for Kubernetes permissions.
data "google_client_openid_userinfo" "terraform_user" {}

data "google_container_cluster" "current_cluster" {
  name     = module.primary-cluster.name
  location = module.primary-cluster.location
}

# set up the gcloud command line tools
//resource "null_resource" "configure_kubectl" {
//  provisioner "local-exec" {
//    command = <<EOH
//  curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-302.0.0-linux-x86_64.tar.gz | tar xz
//  cat <<< '${var.google_credentials}' > google_credentials_keyfile.json
//  ./google-cloud-sdk/bin/gcloud auth activate-service-account --key-file google_credentials_keyfile.json --quiet
//  if ! command -v kubectl; then ./google-cloud-sdk/bin/gcloud components install kubectl --quiet; fi;
//  ./google-cloud-sdk/bin/gcloud container clusters get-credentials "${module.primary-cluster.name}" --region "${var.region}" --project "${var.project}" --quiet
//  EOH
//    # Use environment variables to allow custom kubectl config paths
//    //    environment = {
//    //      KUBECONFIG = local_file.kubeconfig.filename != "" ? local_file.kubeconfig.filename : ""
//    //    }
//
//    interpreter = ["/bin/bash", "-c"]
//  }
//
//  depends_on = [module.primary-cluster]
//}

# download kubectl
//resource "null_resource" "download_kubectl" {
//  provisioner "local-exec" {
//    # command = "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl"
//    command = "if ! command -v kubectl; then ./google-cloud-sdk/bin/gcloud components install kubectl --quiet; fi;"
//  }
//
//  depends_on = [null_resource.setup_gcloud_cli]
//}

# get kubeconfig
//resource "null_resource" "configure_kubectl" {
//  provisioner "local-exec" {
//    command = <<EOH
//      ./google-cloud-sdk/bin/gcloud container clusters get-credentials "${module.primary-cluster.name}" --region "${var.region}" --project "${var.project}" --quiet
//EOH
//  }
//
//  depends_on = [null_resource.setup_gcloud_cli]
//}

# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [module.primary_cluster_auth]
}

# Install ArgoCD using Helm
resource "helm_release" "argocd-bootstrap" {
  name       = "argocd-bootstrap"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  depends_on = [kubernetes_namespace.argocd]

  set {
    name  = "installCRDs"
    value = "false"
  }

  set {
    name  = "config.url"
    type  = "string"
    value = "argocd.honestbank.com"
  }

  set {
    name  = "configs.repositories"
    type  = "string"
    value = <<EOH
      - url: git@github.com:Honestbank/test-argocd-bootstrap.git
        sshPrivateKeySecret:
          name: test-argocd-bootstra-deploy-key
          key: sshPrivateKey
      - type: helm
        url: https://kubernetes-charts.storage.googleapis.com
        name: stable
      - type: helm
        url: https://argoproj.github.io/argo-helm
        name: argo
EOH
  }

  set {
    name  = "configs.repositoryCredentials.test-argocd-bootstra-deploy-key"
    type  = "string"
    value = <<EOH
      -----BEGIN OPENSSH PRIVATE KEY-----
      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
  -----END OPENSSH PRIVATE KEY-----
  EOH
  }

}

# Install Istio Operator using istioctl
//resource "null_resource" "install_istio_operator" {
//  provisioner "local-exec" {
//    command = <<EOH
//curl -sL https://istio.io/downloadIstioctl | sh -
//export PATH=$PATH:$HOME/.istioctl/bin
//istioctl operator init
//kubectl label namespace default istio-injection=enabled
//EOH
//  }
//
//  depends_on = [null_resource.configure_kubectl]
//}

# Set up Kiali credentials
//resource "null_resource" "set_kiali_credentials" {
//  provisioner "local-exec" {
//    command = <<EOH
//kubectl create ns istio-system
//KIALI_USERNAME=$(printf "${var.kiali_username}" | base64)
//echo "Kiali Username (base64): "$KIALI_USERNAME
//KIALI_PASSPHRASE=$(printf "${var.kiali_passphrase}" | base64)
//echo "Kiali Passphrase (base64): "$KIALI_PASSPHRASE
//cat <<EOF | kubectl apply -f -
//apiVersion: v1
//kind: Secret
//metadata:
//  name: kiali
//  namespace: istio-system
//  labels:
//    app: kiali
//type: Opaque
//data:
//  username: $KIALI_USERNAME
//  passphrase: $KIALI_PASSPHRASE
//EOF
//EOH
//  }
//
//  depends_on = [null_resource.configure_kubectl, null_resource.install_istio_operator]
//}

# Install IstioOperator resource manifest to trigger mesh installation
//resource "null_resource" "install_IstioOperator_manifest" {
//  provisioner "local-exec" {
//    command = <<EOH
//cat <<EOF | kubectl apply -f -
//apiVersion: install.istio.io/v1alpha1
//kind: IstioOperator
//metadata:
//  namespace: istio-system
//  name: honestbank-istio-mesh
//spec:
//  profile: default
//  addonComponents:
//    grafana:
//      enabled: true
//    kiali:
//      enabled: true
//EOF
//EOH
//  }
//
//  depends_on = [null_resource.configure_kubectl, null_resource.set_kiali_credentials]
//}

# Install Elastic operator
//resource "null_resource" "install_Elastic_operator" {
//  provisioner "local-exec" {
//    command = <<EOH
//kubectl apply -f https://download.elastic.co/downloads/eck/1.2.0/all-in-one.yaml
//EOH
//  }
//
//  depends_on = [null_resource.configure_kubectl]
//}

# Install Elasticsearch and Kibana
//resource "null_resource" "install_Elastic_resources" {
//  provisioner "local-exec" {
//    command     = <<EOH
//kubectl create -f 'modules/elastic/elastic-basic-cluster.yaml'
//kubectl create -f 'modules/elastic/elastic-filebeat.yaml'
//kubectl create -f 'modules/elastic/elastic-kibana.yaml'
//EOH
//    working_dir = path.module
//  }
//
//  depends_on = [null_resource.configure_kubectl, null_resource.install_Elastic_operator]
//}

# Create namespace for Jaeger
//resource "kubernetes_namespace" "observability" {
//  metadata {
//    name = "observability"
//  }
//
//  depends_on = [null_resource.configure_kubectl]
//}

# Install Jaeger Operator
//resource "helm_release" "jaeger" {
//  name       = "jaeger"
//  repository = "https://jaegertracing.github.io/helm-charts"
//  chart      = "jaeger-operator"
//  namespace  = "observability"
//
//  depends_on = [null_resource.configure_kubectl, kubernetes_namespace.observability]
//}
