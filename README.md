# Terraform scripts for GCP GKE

![Terratest](https://github.com/Honestbank/terraform-gcp-gke/workflows/Terratest/badge.svg) ![Terraform GitHub Actions](https://github.com/Honestbank/terraform-gcp-gke/workflows/Terraform%20GitHub%20Actions/badge.svg)

This script/module creates a basic public GKE cluster.  

## GCP Project Setup

When preparing a GCP project for a Terraform GKE deployment, ensure the
following APIs/services are enabled:

* GKE
* Cloud Resource Manager
* Compute Service
