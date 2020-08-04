# Internal GKE Module

When testing or running locally, run point `terraform` to the `main.tf` file in this folder.

The parent folder wraps this module and combines it with a remote backend.

## Running Locally

Contents of a Google Cloud Platform Service Account JSON keyfile are required,
so when running make sure to `cat` the contents of the file:

```bash
terraform plan -var "google_credentials=$(cat /Users/jai/code/secrets/test-terraform-service-acc-636.json)"
```