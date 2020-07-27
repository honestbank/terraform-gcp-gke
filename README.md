# Terraform scripts for GCP GKE

![Terratest](https://github.com/Honestbank/terraform-gcp-gke/workflows/Terratest/badge.svg) ![Terraform GitHub Actions](https://github.com/Honestbank/terraform-gcp-gke/workflows/Terraform%20GitHub%20Actions/badge.svg)

This script/module creates a basic public GKE cluster.  

## GCP Project Setup

When preparing a GCP project for a Terraform GKE deployment, ensure the
following APIs/services are enabled:

* GKE
* Cloud Resource Manager
* Compute Service

### Service Account

The Service Account used for Terraform operations needs the Owner role in the
project. It might be possible to use the Editor role but currently using the
Editor role returns a 403 error when IAM logWriter Role permissions are being
assigned. Further troubleshooting is needed.
