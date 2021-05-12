# End-to-End Testing

This package uses [Terratest](https://terratest.gruntwork.io) for automatic/E2E 
testing.

To run tests, first export the needed env vars:

```bash
export TF_VAR_google_project="test-terraform-project-compute"
export TF_VAR_google_credentials=$(cat compute.json)
export TF_VAR_shared_vpc_host_google_project="test-terraform-shared-vpc"
export TF_VAR_shared_vpc_host_google_credentials=$(cat vpc.json)
```

Then run the tests:

```bash
go test -v -timeout 30m
```

Tests should always be performed in a separate project (and a separate account, 
if possible) to completely isolate live environments from any potential issues.

## Running in a Docker image

Spin up an Ubuntu docker image from the root of the repo:

```bash
docker run -it -u 0 -v $(pwd):/terraform-test govindani/honest-terraform:0.15 /bin/bash
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

Python:

```bash
apt update && apt install -y python3.8
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

## Manual Cleanup

If the test fails and doesn't clean up after itself properly, you'll want to clean out:

* External IP address in the VPC project
* Cloud Router in the VPC project
* Firewall policies in the VPC project
* GKE cluster in the Compute project
