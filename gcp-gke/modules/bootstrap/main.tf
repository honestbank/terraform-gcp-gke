terraform {
  required_version = ">=0.12.28, <0.14"
}

provider "null" {
  version = "~> 2.1"
}


provider "helm" {
  # Use provider with Helm 3.x support
  version = "~> 1.2.4"

  kubernetes {
    load_config_file = false

    //    host                   = module.primary-cluster.endpoint
    //    cluster_ca_certificate = base64decode(module.primary-cluster.ca_certificate)
    //    token                  = data.google_client_config.default.access_token

    host  = "https://${data.google_container_cluster.current_cluster.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.current_cluster.master_auth[0].cluster_ca_certificate,
    )
  }
}

# We use this data provider to expose an access token for communicating with the GKE cluster.
data "google_client_config" "default" {}

data "google_container_cluster" "current_cluster" {
  name     = var.cluster_name
  location = var.cluster_location
}

resource "null_resource" "write_google_credentials" {
  provisioner "local-exec" {
    command     = "cat <<< '${var.google_credentials}' > google_credentials_keyfile.json"
    interpreter = ["/bin/bash", "-c"]
  }
}

# set up the gcloud command line tools
resource "null_resource" "setup_gcloud_cli" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOH
  curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-302.0.0-linux-x86_64.tar.gz | tar xz
  ./google-cloud-sdk/bin/gcloud auth activate-service-account --key-file google_credentials_keyfile.json --quiet
  EOH
  }

  depends_on = [null_resource.write_google_credentials]
}

# download kubectl
resource "null_resource" "download_kubectl" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOH
if ! command -v kubectl; then curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && alias kubectl="./kubectl"; fi;
EOH
  }
}

# get kubeconfig
resource "null_resource" "configure_kubectl" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOH
      ./google-cloud-sdk/bin/gcloud container clusters get-credentials "${var.cluster_name}" --region "${var.cluster_location}" --project "${var.google_project}" --quiet
EOH
  }

  depends_on = [null_resource.setup_gcloud_cli]
}

# Install Istio Operator using istioctl
resource "null_resource" "install_istio_operator" {
  provisioner "local-exec" {
    command = <<EOH
if ! command -v kubectl; then alias kubectl=./kubectl; fi;
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
if ! command -v kubectl; then alias kubectl=./kubectl; fi;
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
if ! command -v kubectl; then alias kubectl=./kubectl; fi;
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

# Install Elastic operator
resource "null_resource" "install_Elastic_operator" {
  provisioner "local-exec" {
    command = <<EOH
if ! command -v kubectl; then alias kubectl=./kubectl; fi;
kubectl apply -f https://download.elastic.co/downloads/eck/1.2.0/all-in-one.yaml
EOH
  }

  depends_on = [null_resource.configure_kubectl]
}

# Install Elasticsearch and Kibana
resource "null_resource" "install_Elastic_resources" {
  provisioner "local-exec" {
    command = <<EOH
if ! command -v kubectl; then alias kubectl=./kubectl; fi;
kubectl create -f "${path.module}/elastic/elastic-basic-cluster.yaml"
kubectl create -f "${path.module}/elastic/elastic-filebeat.yaml"
kubectl create -f "${path.module}/elastic/elastic-kibana.yaml"
EOH
  }

  depends_on = [null_resource.install_Elastic_operator]
}

# Install Jaeger Operator
resource "helm_release" "jaeger" {
  name             = "telemetry"
  repository       = "https://jaegertracing.github.io/helm-charts"
  chart            = "jaeger-operator"
  namespace        = "observability"
  create_namespace = true

  set {
    name  = "jaeger.create"
    value = "true"
  }

  set {
    name  = "rbac.clusterRole"
    value = "true"
  }
}

### cert-manager (v0.16.1)
# Install cert-manager CRDs
resource "null_resource" "install_cert-manager_crds" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOH
if ! command -v kubectl; then alias kubectl=./kubectl; fi;
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.crds.yaml
EOH
  }

  depends_on = [null_resource.configure_kubectl]
}

# Install cert-manager
resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "0.16.1"
  namespace        = "cert-manager"
  create_namespace = true

  depends_on = [null_resource.install_cert-manager_crds]
}
