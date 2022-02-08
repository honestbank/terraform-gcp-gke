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

output "kubernetes_endpoint" {
  description = "The kubernetes_endpoint output of the google_container_cluster resource."
  value       = google_container_cluster.primary.endpoint
}

output "client_token" {
  sensitive = true
  value     = data.google_client_config.default.access_token
}

output "ca_certificate" {
  sensitive = true
  value     = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

output "gke_kubernetes_master_version" {
  description = "The Kubernetes version installed on the master nodes."
  value       = data.google_container_engine_versions.asiasoutheast2.latest_master_version
}

output "gke_kubernetes_node_version" {
  description = "The Kubernetes version installed on the worker nodes."
  value       = data.google_container_engine_versions.asiasoutheast2.latest_node_version
}

output "node_pool_service_account_email" {
  description = "The default service account used for running nodes"
  value       = google_service_account.default.email
}

output "cluster_name" {
  description = "The GKE cluster name that was built"
  value       = google_container_cluster.primary.name
}

output "cluster_project" {
  description = "The project hosting the GKE cluster."
  value       = google_container_cluster.primary.project
}

output "cluster_primary_node_pool_tag" {
  description = "Tag applied to the node pool instances - used for network/firewall rules."
  value       = local.gke_node_pool_tag
}

output "istio_gatekeeper_firewall_rule_self_link" {
  description = "The self_link attribute of the firewall rule created to allow Gatekeeper and Istio to function."
  value       = google_compute_firewall.gke_private_cluster_istio_gatekeeper_rules.self_link
}

output "rapid_channel_latest_version" {
  description = "The latest version from the RAPID channel with the specified version prefix (min_master_version)."
  value       = data.google_container_engine_versions.asiasoutheast2.release_channel_default_version["RAPID"]
}
