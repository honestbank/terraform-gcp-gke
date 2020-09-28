# End-to-End Testing

This package uses [Terratest](https://terratest.gruntwork.io) for automatic/E2E 
testing.

To run tests, first export the needed env vars:

```bash
export GOOGLE_PROJECT='test-terraform-project-01'
export GOOGLE_CREDENTIALS=$(cat <GCP_SERVICE_ACCOUNT_KEYFILE.JSON>)
export TF_VAR_shared_vpc_host_google_project="test-gcp-project-01-274314"
export TF_VAR_shared_vpc_host_google_credentials=$(cat <GCP_VPC_SERVICE_ACCOUNT_KEYFILE.JSON>)
```

Then run the tests:

```bash
go test -v -timeout 30m
```

Tests should always be performed in a separate project (and a separate account, 
if possible) to completely isolate live environments from any potential issues.

## Running in a Docker image

Spin up an Ubuntu docker image:

```bash
docker run -it -u 0 -v $(pwd):/root groovy /bin/bash
```

### Install Prerequisites

Go:

```bash
cd /tmp
wget https://dl.google.com/go/go1.15.1.linux-amd64.tar.gz
tar -xvf go1.15.1.linux-amd64.tar.gz
export GOROOT="/usr/bin"
cp go/bin/go /usr/bin
```

Terraform:

```bash
curl -O https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip
unzip terraform_0.13.3_linux_amd64.zip
mv terraform /bin
```

Git:

```bash
apt update && apt install -y git
```

### Run Tests

```bash
go test -v -timeout 30m
```
