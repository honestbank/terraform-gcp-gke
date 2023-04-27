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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.9 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.0 |
| <a name="provider_google.compute"></a> [google.compute](#provider\_google.compute) | >= 4.0 |
| <a name="provider_google.vpc"></a> [google.vpc](#provider\_google.vpc) | >= 4.0 |
| <a name="provider_google-beta.compute-beta"></a> [google-beta.compute-beta](#provider\_google-beta.compute-beta) | >= 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_node_pools"></a> [node\_pools](#module\_node\_pools) | ./modules/gcp-gke-node-pool | n/a |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_container_cluster.primary](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_container_cluster) | resource |
| [google-beta_google_container_node_pool.primary_node_pool](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_container_node_pool) | resource |
| [google_compute_firewall.gke_private_cluster_master_to_nodepool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.gke_private_cluster_public_https_firewall_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [random_id.node_pool_tag](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google-beta_google_client_config.default](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/data-sources/google_client_config) | data source |
| [google-beta_google_container_cluster.current_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/data-sources/google_container_cluster) | data source |
| [google_compute_instance.exemplar_node_pool_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance) | data source |
| [google_compute_instance_group.exemplar_node_pool_instance_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance_group) | data source |
| [google_container_cluster.primary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/container_cluster) | data source |
| [google_project.host_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_project.service_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_node_pools"></a> [additional\_node\_pools](#input\_additional\_node\_pools) | A list of objects used to configure additional node pools (in addition to the primary one created by this module by default). | <pre>list(object({<br>    name               = string<br>    machine_type       = string<br>    minimum_node_count = string<br>    maximum_node_count = string<br>    taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>    tags  = list(string)<br>    zones = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_allow_k8s_control_plane"></a> [allow\_k8s\_control\_plane](#input\_allow\_k8s\_control\_plane) | List of ports to allow k8s control plane to communicate with the node pool | `list(string)` | `[]` | no |
| <a name="input_autoscaling_location_policy"></a> [autoscaling\_location\_policy](#input\_autoscaling\_location\_policy) | (Optional) Location policy specifies the algorithm used when scaling-up the node pool. \ "BALANCED" - Is a best effort policy that aims to balance the sizes of available zones. \ "ANY" - Instructs the cluster autoscaler to prioritize utilization of unused reservations, and reduce preemption risk for Spot VMs. | `string` | `"BALANCED"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name to set on the GKE cluster. | `string` | n/a | yes |
| <a name="input_create_gcp_nat"></a> [create\_gcp\_nat](#input\_create\_gcp\_nat) | Set to `true` to create an Internet NAT for ALL\_SUBNETWORKS\_ALL\_IP\_RANGES in the VPC network. | `bool` | n/a | yes |
| <a name="input_create_gcp_router"></a> [create\_gcp\_router](#input\_create\_gcp\_router) | Set to `true` to create a router in the VPC network. | `bool` | n/a | yes |
| <a name="input_create_public_https_firewall_rule"></a> [create\_public\_https\_firewall\_rule](#input\_create\_public\_https\_firewall\_rule) | Set to `true` to create a firewall rule allowing 0.0.0.0/0:443 on TCP to all worker nodes. | `bool` | n/a | yes |
| <a name="input_enable_network_policy"></a> [enable\_network\_policy](#input\_enable\_network\_policy) | This value is passed to network\_policy.enabled and the negative is passed to addons\_config.network\_policy\_config.disabled. | `bool` | n/a | yes |
| <a name="input_gke_authenticator_groups_config_domain"></a> [gke\_authenticator\_groups\_config\_domain](#input\_gke\_authenticator\_groups\_config\_domain) | Domain to append to `gke-security-groups` to pass to authenticator\_groups\_config so members of that Google Group can authenticate to the cluster. Pass an empty string to disable. Domain passed here should be in the format of TLD.EXTENSION. | `string` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | The GCP project to use for this run | `any` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region used to create all resources in this run | `any` | n/a | yes |
| <a name="input_initial_node_count"></a> [initial\_node\_count](#input\_initial\_node\_count) | Initial node count, per-zone for regional clusters. | `any` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The Kubernetes version to install on the master and node pool - must be a valid version from the specified `var.release_channel` | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine types to use for the node pool. | `any` | n/a | yes |
| <a name="input_master_authorized_networks_config_cidr_block"></a> [master\_authorized\_networks\_config\_cidr\_block](#input\_master\_authorized\_networks\_config\_cidr\_block) | The IP range allowed to access the control plane, passed to the master\_authorized\_network\_config.cidr\_blocks.cidr\_block field. | `any` | n/a | yes |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | The IP range to set for master nodes, passed to master\_ipv4\_cidr\_block - /28 required by Google. | `any` | n/a | yes |
| <a name="input_maximum_node_count"></a> [maximum\_node\_count](#input\_maximum\_node\_count) | Maximum nodes for the node pool per-zone. | `any` | n/a | yes |
| <a name="input_minimum_node_count"></a> [minimum\_node\_count](#input\_minimum\_node\_count) | Minimum nodes for the node pool per-zone. | `any` | n/a | yes |
| <a name="input_pods_ip_range_name"></a> [pods\_ip\_range\_name](#input\_pods\_ip\_range\_name) | Name of the secondary IP range used for Kubernetes Pods. | `string` | n/a | yes |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | (Beta) The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `REGULAR`. | `string` | n/a | yes |
| <a name="input_services_ip_range_name"></a> [services\_ip\_range\_name](#input\_services\_ip\_range\_name) | Name of the secondary IP range used for Kubernetes Services. | `string` | n/a | yes |
| <a name="input_shared_vpc_host_google_project"></a> [shared\_vpc\_host\_google\_project](#input\_shared\_vpc\_host\_google\_project) | The GCP project that hosts the VPC to place the GKE cluster in - can be an in-project VPC or a shared VPC. In the case of a shared VPC, the Service Account used to run this module must have permissions to create a Router/NAT in the VPC host project. | `any` | n/a | yes |
| <a name="input_shared_vpc_id"></a> [shared\_vpc\_id](#input\_shared\_vpc\_id) | The id of the shared VPC. | `string` | n/a | yes |
| <a name="input_shared_vpc_self_link"></a> [shared\_vpc\_self\_link](#input\_shared\_vpc\_self\_link) | self\_link of the shared VPC to place the GKE cluster in. | `string` | n/a | yes |
| <a name="input_skip_create_built_in_node_pool"></a> [skip\_create\_built\_in\_node\_pool](#input\_skip\_create\_built\_in\_node\_pool) | Skip creation of the primary node pool that is created with the cluster, and instead use only the `additional_node_pools`.<br>    Note: setting var.skip\_create\_built\_in\_node\_pool to true requires at least one node pool specified in var.additional\_node\_pools" | `bool` | `false` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage: [test, dev, prod...] used as prefix for all resources. | `string` | `"test"` | no |
| <a name="input_subnetwork_self_link"></a> [subnetwork\_self\_link](#input\_subnetwork\_self\_link) | self\_link of the google\_compute\_subnetwork to place the GKE cluster in. | `string` | n/a | yes |
| <a name="input_taints"></a> [taints](#input\_taints) | A list of Kubernetes taints to apply to nodes. GKE's API can only set this field on cluster creation | <pre>list(object({<br>    key    = string<br>    value  = string<br>    effect = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_certificate"></a> [ca\_certificate](#output\_ca\_certificate) | n/a |
| <a name="output_client_token"></a> [client\_token](#output\_client\_token) | n/a |
| <a name="output_cluster_all_primary_node_pool_tags"></a> [cluster\_all\_primary\_node\_pool\_tags](#output\_cluster\_all\_primary\_node\_pool\_tags) | List of tags applied to the node pool instances. This included the managed-by-GCP tags. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The GKE cluster name that was built |
| <a name="output_cluster_primary_node_pool_tag"></a> [cluster\_primary\_node\_pool\_tag](#output\_cluster\_primary\_node\_pool\_tag) | Tag applied to the node pool instances - used for network/firewall rules. |
| <a name="output_cluster_project"></a> [cluster\_project](#output\_cluster\_project) | The project hosting the GKE cluster. |
| <a name="output_kubernetes_endpoint"></a> [kubernetes\_endpoint](#output\_kubernetes\_endpoint) | The kubernetes\_endpoint output of the google\_container\_cluster resource. |
| <a name="output_node_pool_service_account_email"></a> [node\_pool\_service\_account\_email](#output\_node\_pool\_service\_account\_email) | The default service account used for running nodes |
<!-- END_TF_DOCS -->
