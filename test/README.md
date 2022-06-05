# End-to-End Testing

This package uses [Terratest](https://terratest.gruntwork.io) for automatic/E2E
testing.

## Running Tests

1. Select two GCP projects for testing:

   1. Compute service project
   2. Shared VPC host project

1. Ensure [VPC sharing is set up](https://cloud.google.com/vpc/docs/provisioning-shared-vpc) between the two projects.

1. Export the needed env vars:

     ```bash
     export TF_VAR_google_credentials=$(cat <GCP_KEYFILE>.json)
     export TF_VAR_shared_vpc_host_google_credentials=$(cat <GCP_KEYFILE>.json)

     # Examples
     export TF_VAR_google_credentials=$(cat compute.json)
     export TF_VAR_shared_vpc_host_google_credentials=$(cat vpc.json)
     ```

1. Set the project variables:

   1. [`wrapper.auto.tfvars`](./wrapper.auto.tfvars)

      ```terraform
      ### Full GCP project IDs
      google_project                 = "compute-df9f"
      shared_vpc_host_google_project = "tf-shared-vpc-host-78a3"
      ```

   2. [`gke_test.go`](./gke_test.go)

      ```go
      computeProject := "compute-df9f"
      networkingProject := "tf-shared-vpc-host-78a3"
      ```

1. Ensure the GCP projects have the following APIs enabled:

   1. Cloud Resource Manager
   1. Compute Engine
   1. Kubernetes Engine
   1. Service Networking

1. Ensure the Service Accounts have the correct permissions:

    1. Networking Service Account:
       1. Roles in networking project
          1. Owner (this is an easy cop-out)
       2. Roles in the compute project
          1. NONE
       3. Org-level `roles/compute.xpnAdmin` - folders are the lowest-level resource where this role can be granted. If
          permission is set at the folder level, use the `google-beta` provider. The `google` provider requires this
          permission to be set at the organization level. [source - `google_compute_shared_vpc_service_project` docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_shared_vpc_service_project).
    2. Compute Service Account:
       1. Roles in compute project
          1. Owner (this is an easy cop-out)
       2. Roles in networking project (VPC host)
          1. Compute Network User
          2. Kubernetes Engine Host Service Agent User
          3. (not needed?) Security Admin
          4. Info: See https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc#kubernetes_engine_access
    3. Other service accounts:
       1. Compute project default Service Accounts:
          1. <COMPUTE_PROJECT_NUMBER>@cloudservices.gserviceaccount.com
          2. service-<COMPUTE_PROJECT_NUMBER>@container-engine-robot.iam.gserviceaccount.com
          3. Roles:
             1. Compute Network User
             2. Kubernetes Engine Host Service Agent User

### Run Tests

```bash
go test -v -timeout 30m
```

## Manual Cleanup

If the test fails and doesn't clean up after itself properly, you'll want to clean out:

* External IP address in the VPC project
* Cloud Router in the VPC project
* Firewall policies in the VPC project
* GKE cluster in the Compute project
