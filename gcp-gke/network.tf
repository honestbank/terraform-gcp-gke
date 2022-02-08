// tfsec ignore rule because it triggers a false-positive
resource "google_compute_firewall" "gke_private_cluster_istio_gatekeeper_rules" { #tfsec:ignore:google-compute-no-public-ingress
  name    = "honest-${var.cluster_name}-private-cluster-allow"
  network = var.shared_vpc_id

  allow {
    protocol = "tcp"
    ports    = ["15017", "8443"]
  }

  source_ranges = [var.master_ipv4_cidr_block]
  target_tags   = ["gke-${google_container_cluster.primary.name}-node"]

}
