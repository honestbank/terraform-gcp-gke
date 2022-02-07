# End-to-End Testing

This package uses [Terratest](https://terratest.gruntwork.io) for automatic/E2E
testing.

To run tests, first export the needed env vars - values below are examples:

```bash
export TF_VAR_google_credentials=$(cat compute.json)
export TF_VAR_shared_vpc_host_google_credentials=$(cat vpc.json)
```

Then run the tests:

```bash
go test -v -timeout 60m
```

Tests should always be performed in a separate project (and a separate account,
if possible) to completely isolate live environments from any potential issues.

## Running in a Docker image

Spin up an Ubuntu docker image from the root of the repo:

```bash
docker run -it -u 0 -v $(pwd):/terraform-test govindani/honest_terraform:0.15 /bin/bash
docker run -it -u 0 -v $(pwd):/terraform-test ubuntu /bin/bash
```

### Install Prerequisites

See [prepare-test-environment.sh](./prepare-test-environment.sh) for requirements.
Or just `source` the script 😊

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
