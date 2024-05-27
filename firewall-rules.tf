locals {
  honest_bkk_office_cidrs = [
    "49.229.55.242/32",
  ]
  honest_tailscale_cidrs = [
    "35.219.4.69/32",
  ]
  confluent_bastion_rule_name = "confluent-bastion-${var.stage}"
  runnable_stage_rule_name    = toset(contains(["dev", "stage", "prod"], var.stage) ? [local.confluent_bastion_rule_name] : [])
}

resource "google_compute_firewall" "confluent_cloud_bastion" {
  for_each = local.runnable_stage_rule_name

  name    = each.key
  network = var.shared_vpc_self_link

  direction     = "INGRESS"
  source_ranges = concat(local.honest_bkk_office_cidrs, local.honest_tailscale_cidrs)
  target_tags = [
    "confluent-bastion",
  ]
  allow {
    protocol = "tcp"
    ports = [
      "22",
    ]
  }
}

import {
  for_each = local.runnable_stage_rule_name
  to       = google_compute_firewall.confluent_cloud_bastion
  id       = each.key
}
