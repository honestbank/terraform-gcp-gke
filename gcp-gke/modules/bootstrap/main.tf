terraform {
  required_version = ">=0.12.28, <0.14"
}

provider "helm" {
  # Use provider with Helm 3.x support
  version = "~> 1.2.4"

  kubernetes {
    load_config_file = false

    host                   = var.cluster_host
    token                  = var.cluster_token
    cluster_ca_certificate = var.cluster_ca_certificate
  }
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

resource "kubernetes_namespace" "istio_system_namespace" {
  metadata {
    name = "istio-system"
  }
}

# Set up Kiali credentials
resource "kubernetes_secret" "kiali_credentials" {
  metadata {
    name      = "kiali"
    namespace = "istio-system"

    annotations = {
      "meta.helm.sh/release-name"      = "argocd"
      "meta.helm.sh/release-namespace" = "argocd"
    }

    labels = {
      "app" = "kiali"
    }
  }

  data = {
    "username"   = base64(var.kiali_username)
    "passphrase" = base64(var.kiali_passphrase)
  }

  type = "Opaque"

  depends_on = [kubernetes_namespace.istio_system_namespace]
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
