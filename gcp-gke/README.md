# Terraform Local-Backend Module for GCP (Google Cloud Platform) GKE (Google Kubernetes Engine) Build

Since Terratest doesn't yet support specifying a backend config file via command-line arguments,
this internal/external module structure is required to enable E2E testing using Terratest.

See our [How to structure a Terraform module Notion page](https://www.notion.so/honestbank/How-to-structure-a-Terraform-module-31374a1594f84ef7b185ef4e06b36619)
for more details on Terraform module structuring.

This folder can be init'ed and applied using Terraform to test functionality.

To run E2E tests, navigate to the [test folder](../test) and run `go test -v -timeout 30m`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.9.0 |
| <a name="provider_google.compute"></a> [google.compute](#provider\_google.compute) | 4.9.0 |
| <a name="provider_google.vpc"></a> [google.vpc](#provider\_google.vpc) | 4.9.0 |
| <a name="provider_google-beta.compute-beta"></a> [google-beta.compute-beta](#provider\_google-beta.compute-beta) | 4.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_container_cluster.primary](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_container_cluster) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_container_node_pool.primary_node_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google-beta_google_client_config.default](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/data-sources/google_client_config) | data source |
| [google-beta_google_container_cluster.current_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/data-sources/google_container_cluster) | data source |
| [google_project.host_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_project.service_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name to set on the GKE cluster. | `string` | n/a | yes |
| <a name="input_gke_authenticator_groups_config"></a> [gke\_authenticator\_groups\_config](#input\_gke\_authenticator\_groups\_config) | Value to pass to authenticator\_groups\_config so members of that Google Group can authenticate to the cluster. Pass an empty string to disable. | `string` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | The GCP project to use for this run | `any` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region used to create all resources in this run | `any` | n/a | yes |
| <a name="input_initial_node_count"></a> [initial\_node\_count](#input\_initial\_node\_count) | Initial node count, per-zone for regional clusters. | `any` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine types to use for the node pool. | `any` | n/a | yes |
| <a name="input_maximum_node_count"></a> [maximum\_node\_count](#input\_maximum\_node\_count) | Maximum nodes for the node pool per-zone. | `any` | n/a | yes |
| <a name="input_min_master_version"></a> [min\_master\_version](#input\_min\_master\_version) | The min\_master\_version attribute to pass to the google\_container\_cluster resource. | `any` | n/a | yes |
| <a name="input_minimum_node_count"></a> [minimum\_node\_count](#input\_minimum\_node\_count) | Minimum nodes for the node pool per-zone. | `any` | n/a | yes |
| <a name="input_pods_ip_range_name"></a> [pods\_ip\_range\_name](#input\_pods\_ip\_range\_name) | Name of the secondary IP range used for Kubernetes Pods. | `string` | n/a | yes |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | (Beta) The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `REGULAR`. | `string` | `"RAPID"` | no |
| <a name="input_services_ip_range_name"></a> [services\_ip\_range\_name](#input\_services\_ip\_range\_name) | Name of the secondary IP range used for Kubernetes Services. | `string` | n/a | yes |
| <a name="input_shared_vpc_host_google_project"></a> [shared\_vpc\_host\_google\_project](#input\_shared\_vpc\_host\_google\_project) | The GCP project that hosts the VPC to place the GKE cluster in - can be an in-project VPC or a shared VPC. In the case of a shared VPC, | `any` | n/a | yes |
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
| <a name="output_kubernetes_endpoint"></a> [kubernetes\_endpoint](#output\_kubernetes\_endpoint) | The kubernetes\_endpoint output of the google\_container\_cluster resource. |
| <a name="output_node_pool_service_account_email"></a> [node\_pool\_service\_account\_email](#output\_node\_pool\_service\_account\_email) | The default service account used for running nodes |
<!-- END_TF_DOCS -->
