/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "ca_certificate" {
  sensitive = true
  value     = module.gke.ca_certificate
}

output "client_token" {
  sensitive = true
  value     = module.gke.client_token
}

output "cluster_name" {
  description = "The GKE cluster name that was built"
  value       = module.gke.cluster_name
}

output "cluster_project" {
  description = "The project hosting the GKE cluster."
  value       = module.gke.cluster_project
}

output "gke_cluster_istio_gatekeeper_firewall_rule_self_link" {
  description = "The tags applied to the primary node pool of the GKE cluster."
  value       = module.gke.istio_gatekeeper_firewall_rule_self_link
}

output "gke_cluster_primary_node_pool_tag" {
  description = "Tag applied to the node pool instances - used for network/firewall rules."
  value       = module.gke.cluster_primary_node_pool_tag
}


output "gke_kubernetes_latest_master_version" {
  description = "The `latest_master_version` attribute of the `google_container_engine_versions` data source."
  value       = module.gke.google_container_engine_versions_data_latest_master_version
}

output "gke_kubernetes_latest_node_version" {
  description = "The `latest_node_version` attribute of the `google_container_engine_versions` data source."
  value       = module.gke.google_container_engine_versions_data_latest_node_version
}

output "gke_kubernetes_valid_master_versions" {
  description = "The `valid_master_versions` attribute of the `google_container_engine_versions` data source."
  value       = module.gke.google_container_engine_versions_data_valid_master_versions
}

output "gke_kubernetes_valid_node_versions" {
  description = "The `valid_node_versions` attribute of the `google_container_engine_versions` data source."
  value       = module.gke.google_container_engine_versions_data_valid_node_versions
}

output "rapid_channel_default_version" {
  description = "The default version from the RAPID channel with the specified version prefix (min_master_version)."
  value       = module.gke.rapid_channel_default_version
}

output "google_container_engine_versions_data" {
  description = "The data returned by the `google_container_engine_versions` data source."
  value       = module.gke.google_container_engine_versions_data
}

output "kubernetes_endpoint" {
  sensitive = true
  value     = module.gke.kubernetes_endpoint
}

output "service_account" {
  description = "The default service account used for running nodes."
  value       = module.gke.node_pool_service_account_email
}
