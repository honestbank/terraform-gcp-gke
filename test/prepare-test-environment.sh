export GOOGLE_PROJECT='test-terraform-project-01'
export GOOGLE_CREDENTIALS=$(cat ../gcp-gke/compute.json)
export TF_VAR_shared_vpc_host_google_project="test-gcp-project-01-274314"
export TF_VAR_shared_vpc_host_google_credentials=$(cat ../gcp-gke/vpc.json)

apt update 

if ! command -v kubectl; then
  # apt install -y apt-transport-https gnupg2 curl
  # curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  # apt install -y kubectl
  apt-get update && apt-get install -y apt-transport-https gnupg2 curl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
  apt-get update
  apt-get install -y kubectl
fi

if ! command -v git; then
  apt install -y git
fi

if ! command -v go; then
  cd /tmp || mkdir /tmp && cd /tmp
  wget -O go.tgz https://dl.google.com/go/go1.15.1.linux-amd64.tar.gz
  tar -C /usr/local -xvf go.tgz
  export PATH="/usr/local/go/bin:$PATH"
  export GOPATH=/opt/go/
  export PATH=$PATH:$GOPATH/bin
fi

if ! command -v unzip; then
 apt install -y unzip
fi


if ! command -v terraform; then
  curl -O https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
  unzip terraform_0.13.5_linux_amd64.zip
  mv terraform /usr/bin
  terraform version || return
fi

if ! command -v gcc; then
  apt install -y gcc
fi

if ! command -v python; then
  apt install -y python
fi

if ! ls ~/.kube; then
  mkdir ~/.kube
fi

if ! ls ~/.kube/config; then
  touch ~/.kube/config
fi
