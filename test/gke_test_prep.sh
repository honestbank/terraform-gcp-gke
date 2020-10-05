export GOOGLE_PROJECT='test-terraform-project-01'
export GOOGLE_CREDENTIALS=$(cat ../gcp-gke/compute.json)
export TF_VAR_shared_vpc_host_google_project="test-gcp-project-01-274314"
export TF_VAR_shared_vpc_host_google_credentials=$(cat ../gcp-gke/vpc.json)

cd /tmp || mkdir /tmp && cd /tmp
wget -O go.tgz https://dl.google.com/go/go1.15.1.linux-amd64.tar.gz
tar -C /usr/local -xvf go.tgz
export PATH="/usr/local/go/bin:$PATH"
export GOPATH=/opt/go/
export PATH=$PATH:$GOPATH/bin

cp go/bin/go /usr/bin
go version || return

curl -O https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip
unzip terraform_0.13.3_linux_amd64.zip
mv terraform /usr/bin
terraform version || return

apt update && apt install -y git
apt install -y gcc

cd /root
mkdir .kube
touch .kube/config
