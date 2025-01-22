# Terraform Modules for GCP GKE

![terratest](https://github.com/Honestbank/terraform-gcp-gke/workflows/terratest/badge.svg?branch=main)
![Terraform GitHub Actions](https://github.com/Honestbank/terraform-gcp-gke/workflows/Terraform%20GitHub%20Actions/badge.svg)

This module creates a basic public GKE cluster located in a shared VPC.

## GCP Project Setup

When preparing a GCP project for a Terraform GKE deployment, ensure the
following APIs/services are enabled:

* Cloud Resource Manager
* Compute Engine
* Kubernetes Engine
* Service Networking

### Networking

This module requires a shared VPC, and assumes that the main project specified by
`google_project` is a 'service project' that is attached to a shared VPC originating
in `shared_vpc_host_google_project`.

Ensure that the secondary IP ranges for Pods and Services in the shared VPC are not used by another
cluster, otherwise this module will time out/fail.

**Network and Subnet Names**

Some assumptions are made regarding the name of the shared VPC network, subnet, and
IP ranges for Pods and Services:

* Shared VPC network name = `<STAGE>-private-vpc` (eg. `test-private-vpc`)
* Shared VPC subnet name = `<STAGE>-private-vpc-subnet` (eg. `test-private-vpc-subnet`)
* Shared VPC subnet Pods IP range name = `<STAGE>-private-vpc-pods` (eg. `test-private-vpc-pods`)
* Shared VPC subnet Services IP range name = `<STAGE>-private-vpc-services` (eg. `test-private-vpc-services`)

### Service Account Permissions

The GCP Service Account used by the `compute` Google provider (that builds the GKE cluster) requires the `compute.networkUser`
role in the shared VPC host project.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
