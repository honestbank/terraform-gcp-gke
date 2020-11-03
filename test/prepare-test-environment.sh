export GOOGLE_PROJECT='test-terraform-project-01'
export GOOGLE_CREDENTIALS=$(cat ../gcp-gke/compute.json)
export TF_VAR_shared_vpc_host_google_project="test-gcp-project-01-274314"
export TF_VAR_shared_vpc_host_google_credentials=$(cat ../gcp-gke/vpc.json)

if ! command -v go; then
  cd /tmp || mkdir /tmp && cd /tmp
  wget -O go.tgz https://dl.google.com/go/go1.15.1.linux-amd64.tar.gz
  tar -C /usr/local -xvf go.tgz
  export PATH="/usr/local/go/bin:$PATH"
  export GOPATH=/opt/go/
  export PATH=$PATH:$GOPATH/bin
fi

if ! command -v terraform; then
  curl -O https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip
  unzip terraform_0.13.4_linux_amd64.zip
  mv terraform /usr/bin
  terraform version || return
fi

apt update && apt install -y git

if ! command -v gcc; then
  apt install -y gcc
fi

if ! command -v python; then
  apt install -y python
fi

if ! ls ~/.kube/config; then
  touch ~/.kube/config
fi
