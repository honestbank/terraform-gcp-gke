# Terraform Modules for GCP GKE

![terratest](https://github.com/Honestbank/terraform-gcp-gke/workflows/terratest/badge.svg?branch=main)
![Terraform GitHub Actions](https://github.com/Honestbank/terraform-gcp-gke/workflows/Terraform%20GitHub%20Actions/badge.svg)

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
* Compute Engine
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

The `shared_vpc_host_google_credentials` Service Account requires the permissions listed below.
It is recommended to create a custom role named `Terraform Shared VPC Role` with ID
`terraform_shared_vpc_host_role` for convenient management:

* `resourcemanager.projects.get`
* `resourcemanager.projects.getIamPolicy`
* `resourcemanager.projects.setIamPolicy`

## Cluster Infrastructure

### Tracing/Telemetry

A Jaeger instance is deployed to the `observability` namespace with an endpoint
accessible at `telemetry-jaeger-operator-jaeger-agent.observability.svc.cluster.local`
with ports `5775/UDP,5778/TCP,6831/UDP,6832/UDP`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | ./gcp-gke | n/a |

## Resources

| Name | Type |
|------|------|
| [random_id.run_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gke_authenticator_groups_config"></a> [gke\_authenticator\_groups\_config](#input\_gke\_authenticator\_groups\_config) | Value to pass to authenticator\_groups\_config so members of that Google Group can authenticate to the cluster. Pass an empty string to disable. | `string` | n/a | yes |
| <a name="input_google_credentials"></a> [google\_credentials](#input\_google\_credentials) | Contents of a JSON keyfile of an account with write access to the project | `any` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | The GCP project to use for this run | `any` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region used to create all resources in this run | `any` | n/a | yes |
| <a name="input_initial_node_count"></a> [initial\_node\_count](#input\_initial\_node\_count) | Initial node count, per-zone for regional clusters. | `any` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine types to use for the node pool. | `string` | n/a | yes |
| <a name="input_maximum_node_count"></a> [maximum\_node\_count](#input\_maximum\_node\_count) | Maximum nodes for the node pool. This is the total nodes so for regional deployments it is the total nodes across all zones. | `string` | n/a | yes |
| <a name="input_min_master_version"></a> [min\_master\_version](#input\_min\_master\_version) | The min\_master\_version attribute to pass to the google\_container\_cluster resource. | `string` | n/a | yes |
| <a name="input_minimum_node_count"></a> [minimum\_node\_count](#input\_minimum\_node\_count) | Minimum nodes for the node pool. This is the total nodes so for regional deployments it is the total nodes across all zones. | `string` | n/a | yes |
| <a name="input_pods_ip_range_cidr"></a> [pods\_ip\_range\_cidr](#input\_pods\_ip\_range\_cidr) | CIDR of the secondary IP range used for Kubernetes Pods. | `string` | n/a | yes |
| <a name="input_pods_ip_range_name"></a> [pods\_ip\_range\_name](#input\_pods\_ip\_range\_name) | Name of the secondary IP range used for Kubernetes Pods. | `string` | n/a | yes |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | (Beta) The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `REGULAR`. | `string` | `"RAPID"` | no |
| <a name="input_services_ip_range_cidr"></a> [services\_ip\_range\_cidr](#input\_services\_ip\_range\_cidr) | CIDR of the secondary IP range used for Kubernetes Services. | `string` | n/a | yes |
| <a name="input_services_ip_range_name"></a> [services\_ip\_range\_name](#input\_services\_ip\_range\_name) | Name of the secondary IP range used for Kubernetes Services. | `string` | n/a | yes |
| <a name="input_shared_vpc_host_google_credentials"></a> [shared\_vpc\_host\_google\_credentials](#input\_shared\_vpc\_host\_google\_credentials) | Service Account with access to shared\_vpc\_host\_google\_project networks | `any` | n/a | yes |
| <a name="input_shared_vpc_host_google_project"></a> [shared\_vpc\_host\_google\_project](#input\_shared\_vpc\_host\_google\_project) | The GCP project that hosts the shared VPC to place resources into | `any` | n/a | yes |
| <a name="input_shared_vpc_id"></a> [shared\_vpc\_id](#input\_shared\_vpc\_id) | The id of the shared VPC. | `string` | n/a | yes |
| <a name="input_shared_vpc_self_link"></a> [shared\_vpc\_self\_link](#input\_shared\_vpc\_self\_link) | self\_link of the shared VPC to place the GKE cluster in. | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage: [test, dev, prod...] used as prefix for all resources. | `string` | `"test"` | no |
| <a name="input_subnetwork_self_link"></a> [subnetwork\_self\_link](#input\_subnetwork\_self\_link) | self\_link of the google\_compute\_subnetwork to place the GKE cluster in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_certificate"></a> [ca\_certificate](#output\_ca\_certificate) | n/a |
| <a name="output_client_token"></a> [client\_token](#output\_client\_token) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The GKE cluster name that was built |
| <a name="output_cluster_project"></a> [cluster\_project](#output\_cluster\_project) | The project hosting the GKE cluster. |
| <a name="output_kubernetes_endpoint"></a> [kubernetes\_endpoint](#output\_kubernetes\_endpoint) | n/a |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The default service account used for running nodes. |
<!-- END_TF_DOCS -->
