# Terraform Modules for GCP GKE

![Terratest](https://github.com/Honestbank/terraform-gcp-gke/workflows/Terratest/badge.svg) ![Terraform GitHub Actions](https://github.com/Honestbank/terraform-gcp-gke/workflows/Terraform%20GitHub%20Actions/badge.svg)

This script/module creates a basic public GKE cluster located in a shared VPC.

## Inputs

* `google_region` - region in which to create resources.
* `zones` - zones to place compute resources in (defaults to `["asia-southeast2-a", "asia-southeast2-b", "asia-southeast2-c"]`).
* `google_project` - project in which to place compute resources (defaults to `test-api-cloud-infrastructure`).
* `google_credentials` - service account with ability to create resources in `google_project`.
* `shared_vpc_host_google_project` - host project of the shared VPC (defaults to `test-api-shared-vpc`).
* `shared_vpc_host_google_credentials` - service account with ability to read/get networks from 
  `shared_vpc_host_google_project`
* `stage` - prefix for all resources (defaults to `test`).
* `cluster_purpose` - placed into the cluster's name (defaults to `tf-gke-template`).
* `cluster_number` - a count index suffix for compute resources (defaults to `00`).

**TODO:** Add remaining variables

To run locally,export the following variables:

```bash
export TF_VAR_google_region="asia-southeast2"
export TF_VAR_google_project=
export TF_VAR_google_credentials=
export TF_VAR_shared_vpc_host_google_project=
export TF_VAR_shared_vpc_host_google_credentials= 
```

## GCP Project Setup

When preparing a GCP project for a Terraform GKE deployment, ensure the
following APIs/services are enabled:

* GKE
* Cloud Resource Manager
* Compute Service
* Service Networking

### Networking

This script requires a shared VPC, and assumes that the main project specified by
`google_project` is a 'service project' that is attached to a shared VPC originating
in `shared_vpc_host_google_project`.

Ensure that the secondary IP ranges for Pods and Services in the shared VPC are not used by another
cluster, otherwise this script will time out/fail.

**Network and Subnet Names**

Some assumptions are made regarding the name of the shared VPC network, subnet, and
IP ranges for Pods and Services:

* Shared VPC network name = `<STAGE>-private-vpc` (eg. `test-private-vpc`)
* Shared VPC subnet name = `<STAGE>-private-vpc-subnet` (eg. `test-private-vpc-subnet`)
* Shared VPC subnet Pods IP range name = `<STAGE>-private-vpc-pods` (eg. `test-private-vpc-pods`)
* Shared VPC subnet Services IP range name = `<STAGE>-private-vpc-services` (eg. `test-private-vpc-services`)

### Service Account

The Service Account specified in `google_credentials` requires:

* Role: Project Owner (in main project) - The Service Account used for Terraform operations needs 
the Owner role in the project. It might be possible to use the Editor role but 
currently using the Editor role returns a 403 error when IAM logWriter Role 
permissions are being assigned. Further troubleshooting is needed.

The Service Account specified in `shared_vpc_host_google_credentials` requires:

* The ability to list networks/subnetworks in `shared_vpc_host_google_project`

## Cluster Infrastructure

### Logging

The Elastic operator for Kubernetes is deployed along with Filebeat for automatic log
collection from Pods.

### Tracing/Telemetry

A Jaeger instance is deployed to the `observability` namespace with an endpoint
accessible at `telemetry-jaeger-operator-jaeger-agent.observability.svc.cluster.local`
with ports `5775/UDP,5778/TCP,6831/UDP,6832/UDP`
