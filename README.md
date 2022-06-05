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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | ./modules/gcp-gke | n/a |

## Resources

| Name | Type |
|------|------|
| [random_id.run_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_gcp_nat"></a> [create\_gcp\_nat](#input\_create\_gcp\_nat) | Set to `true` to create an Internet NAT for ALL\_SUBNETWORKS\_ALL\_IP\_RANGES in the VPC network. | `bool` | n/a | yes |
| <a name="input_create_gcp_router"></a> [create\_gcp\_router](#input\_create\_gcp\_router) | Set to `true` to create a router in the VPC network. | `bool` | n/a | yes |
| <a name="input_create_public_https_firewall_rule"></a> [create\_public\_https\_firewall\_rule](#input\_create\_public\_https\_firewall\_rule) | Set to `true` to create a firewall rule allowing 0.0.0.0/0:443 on TCP to all worker nodes. | `bool` | n/a | yes |
| <a name="input_enable_network_policy"></a> [enable\_network\_policy](#input\_enable\_network\_policy) | This value is passed to network\_policy.enabled and the negative is passed to addons\_config.network\_policy\_config.disabled. This might conflict with Workload Identity - make sure to read https://cloud.google.com/kubernetes-engine/docs/how-to/network-policy#limitations_and_requirements. | `bool` | n/a | yes |
| <a name="input_gke_authenticator_groups_config_domain"></a> [gke\_authenticator\_groups\_config\_domain](#input\_gke\_authenticator\_groups\_config\_domain) | Domain to append to `gke-security-groups` to pass to authenticator\_groups\_config so members of that Google Group can authenticate to the cluster. Pass an empty string to disable. Domain passed here should be in the format of TLD.EXTENSION. | `string` | n/a | yes |
| <a name="input_google_credentials"></a> [google\_credentials](#input\_google\_credentials) | Contents of a JSON keyfile of an account with write access to the project | `any` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | The GCP project to use for this run | `any` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region used to create all resources in this run | `any` | n/a | yes |
| <a name="input_initial_node_count"></a> [initial\_node\_count](#input\_initial\_node\_count) | Initial node count, per-zone for regional clusters. | `any` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The Kubernetes version to install on the master and node pool - must be a valid version from the specified `var.release_channel` | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine types to use for the node pool. | `string` | n/a | yes |
| <a name="input_master_authorized_networks_config_cidr_block"></a> [master\_authorized\_networks\_config\_cidr\_block](#input\_master\_authorized\_networks\_config\_cidr\_block) | The IP range allowed to access the control plane, passed to the master\_authorized\_network\_config.cidr\_blocks.cidr\_block field. | `any` | n/a | yes |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | The IP range to set for master nodes, passed to master\_ipv4\_cidr\_block - /28 required by Google. | `any` | n/a | yes |
| <a name="input_maximum_node_count"></a> [maximum\_node\_count](#input\_maximum\_node\_count) | Maximum nodes for the node pool. This is the total nodes so for regional deployments it is the total nodes across all zones. | `string` | n/a | yes |
| <a name="input_minimum_node_count"></a> [minimum\_node\_count](#input\_minimum\_node\_count) | Minimum nodes for the node pool. This is the total nodes so for regional deployments it is the total nodes across all zones. | `string` | n/a | yes |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | The number of nodes per instance group. This field can be used to update the number of nodes per instance group but should not be used alongside autoscaling. Node count management in this module needs to be refactored. See https://linear.app/honestbank/issue/DEVOP-819/incorrect-node-pool-size-management-in-terraform-gcp-gke. | `number` | n/a | yes |
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
| <a name="output_gke_cluster_istio_gatekeeper_firewall_rule_self_link"></a> [gke\_cluster\_istio\_gatekeeper\_firewall\_rule\_self\_link](#output\_gke\_cluster\_istio\_gatekeeper\_firewall\_rule\_self\_link) | The tags applied to the primary node pool of the GKE cluster. |
| <a name="output_gke_cluster_primary_node_pool_tag"></a> [gke\_cluster\_primary\_node\_pool\_tag](#output\_gke\_cluster\_primary\_node\_pool\_tag) | Tag applied to the node pool instances - used for network/firewall rules. |
| <a name="output_kubernetes_endpoint"></a> [kubernetes\_endpoint](#output\_kubernetes\_endpoint) | n/a |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The default service account used for running nodes. |
<!-- END_TF_DOCS -->
