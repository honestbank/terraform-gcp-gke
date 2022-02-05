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

output "cluster_nat_ips" {
  description = "The external NAT IP address used by the GKE cluster for internet access"
  value       = module.gke.cluster_nat_ips
}

output "cluster_project" {
  description = "The project hosting the GKE cluster."
  value       = module.gke.cluster_project
}

output "kubernetes_endpoint" {
  sensitive = true
  value     = module.gke.kubernetes_endpoint
}

output "service_account" {
  description = "The default service account used for running nodes."
  value       = module.gke.node_pool_service_account_email
}
