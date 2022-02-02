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
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google.compute"></a> [google.compute](#provider\_google.compute) | ~> 3.0 |
| <a name="provider_google.vpc"></a> [google.vpc](#provider\_google.vpc) | ~> 3.0 |
| <a name="provider_google-beta.compute-beta"></a> [google-beta.compute-beta](#provider\_google-beta.compute-beta) | ~> 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_nat"></a> [cloud\_nat](#module\_cloud\_nat) | terraform-google-modules/cloud-nat/google | ~> 1.3.0 |
| <a name="module_primary-cluster"></a> [primary-cluster](#module\_primary-cluster) | ./modules/terraform-google-kubernetes-engine/modules/beta-private-cluster-update-variant | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.cloud_nat_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_project_iam_binding.compute-network-user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [random_id.run_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google-beta_google_client_config.default](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/data-sources/google_client_config) | data source |
| [google-beta_google_container_cluster.current_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/data-sources/google_container_cluster) | data source |
| [google_project.host_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_project.service_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_number"></a> [cluster\_number](#input\_cluster\_number) | n/a | `number` | `0` | no |
| <a name="input_cluster_purpose"></a> [cluster\_purpose](#input\_cluster\_purpose) | Name to assign to GKE cluster built in this run. | `string` | `"tf-gke-template"` | no |
| <a name="input_google_credentials"></a> [google\_credentials](#input\_google\_credentials) | Contents of a JSON keyfile of an account with write access to the project | `any` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | The GCP project to use for this run | `any` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region used to create all resources in this run | `any` | n/a | yes |
| <a name="input_initial_node_count"></a> [initial\_node\_count](#input\_initial\_node\_count) | Initial node count, per-zone for regional clusters. | `number` | `1` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine types to use for the node pool. | `string` | `"n1-standard-2"` | no |
| <a name="input_maximum_node_count"></a> [maximum\_node\_count](#input\_maximum\_node\_count) | Maximum nodes for the node pool per-zone. | `number` | `1` | no |
| <a name="input_minimum_node_count"></a> [minimum\_node\_count](#input\_minimum\_node\_count) | Minimum nodes for the node pool per-zone. | `number` | `1` | no |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | (Beta) The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `REGULAR`. | `string` | `"RAPID"` | no |
| <a name="input_shared_vpc_host_google_credentials"></a> [shared\_vpc\_host\_google\_credentials](#input\_shared\_vpc\_host\_google\_credentials) | Service Account with access to shared\_vpc\_host\_google\_project networks | `any` | n/a | yes |
| <a name="input_shared_vpc_host_google_project"></a> [shared\_vpc\_host\_google\_project](#input\_shared\_vpc\_host\_google\_project) | The GCP project that hosts the shared VPC to place resources into | `any` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage: [test, dev, prod...] used as prefix for all resources. | `string` | `"test"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Zones for the VMs in the cluster. Default is set to Jakarta (all zones). | `list` | <pre>[<br>  "asia-southeast2-a",<br>  "asia-southeast2-b",<br>  "asia-southeast2-c"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_certificate"></a> [ca\_certificate](#output\_ca\_certificate) | n/a |
| <a name="output_client_token"></a> [client\_token](#output\_client\_token) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The GKE cluster name that was built |
| <a name="output_cluster_nat_ips"></a> [cluster\_nat\_ips](#output\_cluster\_nat\_ips) | The external NAT IP address used by the GKE cluster for internet access |
| <a name="output_kubernetes_endpoint"></a> [kubernetes\_endpoint](#output\_kubernetes\_endpoint) | n/a |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The default service account used for running nodes |
<!-- END_TF_DOCS -->
