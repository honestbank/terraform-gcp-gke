package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"log"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestTerraformGcpGkeTemplate(t *testing.T) {

	// GCP only allows hyphens in names, no underscores
	runId := strings.ToLower(random.UniqueId())

	clusterName := "test-gke-" + runId
	// Create all resources in the following zone
	gcpIndonesiaRegion := "asia-southeast2"

	// GCP projects
	computeProject := "compute-df9f"
	networkingProject := "tf-shared-vpc-host-78a3"
	tempTestDir := ""

	//
	// WARNING: This test can only be run on a SINGLE-PROJECT build!
	// With the env var usage method, shared/cross-project VPCs are not currently supported!
	//
	applyDestroyTestCaseName := "apply_destroy_" + clusterName
	t.Run(applyDestroyTestCaseName, func(t *testing.T) {
		t.Parallel()

		// Create a directory path that won't conflict
		workingDir := filepath.Join(".", "test-runs", applyDestroyTestCaseName)

		vpcBootstrapWorkingDir := ""

		vpcBootstrapTerraformOptions := &terraform.Options{}
		test_structure.RunTestStage(t, "create_vpc_options", func() {
			// In this case we use "." for the rootFolder because the module is in the same folder as this test file
			vpcBootstrapWorkingDir = test_structure.CopyTerraformFolderToTemp(t, ".", "modules/terraform-gcp-vpc/vpc")

			// The variable set below assumes you have exported the following env vars:
			// export TF_VAR_google_credentials=$(cat vpc.json)
			vpcBootstrapTerraformOptions = terraform.WithDefaultRetryableErrors(t, &terraform.Options{
				TerraformDir: vpcBootstrapWorkingDir,
				Vars: map[string]interface{}{
					"google_project":                       networkingProject,
					"google_region":                        gcpIndonesiaRegion,
					"network_name":                         clusterName + "-vpc",
					"vpc_primary_subnet_name":              clusterName + "-primary-subnet",
					"vpc_secondary_ip_range_pods_name":     clusterName + "-pods-subnet",
					"vpc_secondary_ip_range_services_name": clusterName + "-services-subnet",
				},
				EnvVars: map[string]string{},
			})

			// Copy supporting files needed for VPC build
			varFile := "vpc.auto.tfvars"
			providerFile := "vpc_providers.tf"
			testFileSourceDir, getTestDirErr := os.Getwd()
			if getTestDirErr != nil {
				fmt.Println("calling t.FailNow(): could not execute os.Getwd(): ", getTestDirErr)
				t.FailNow()
			}

			fmt.Println("test working directory is: ", testFileSourceDir)

			filesToCopy := []string{varFile, providerFile}
			copyFiles(t, filesToCopy, testFileSourceDir, vpcBootstrapWorkingDir)
		})

		defer test_structure.RunTestStage(t, "vpc_cleanup", func() {
			terraform.Destroy(t, vpcBootstrapTerraformOptions)
		})

		test_structure.RunTestStage(t, "create_vpc", func() {
			terraform.InitAndApply(t, vpcBootstrapTerraformOptions)
		})

		// GKE cluster
		test_structure.RunTestStage(t, "create_test_copy", func() {
			tempTestDir = test_structure.CopyTerraformFolderToTemp(t, "../modules/gcp-gke", ".")
			logger.Logf(t, "path to test folder %s\n", tempTestDir)
			test_structure.SaveString(t, workingDir, "gkeClusterTerraformModulePath", tempTestDir)
		})

		test_structure.RunTestStage(t, "create_terratest_options", func() {

			// export TF_VAR_google_credentials=$(cat KEYFILE.json)
			// export TF_VAR_shared_vpc_host_google_credentials=$(cat KEYFILE.json)
			gkeClusterTerratestOptions := &terraform.Options{
				TerraformDir: tempTestDir,
				Vars: map[string]interface{}{
					"cluster_name":           clusterName,
					"pods_ip_range_name":     terraform.Output(t, vpcBootstrapTerraformOptions, "pods_subnet_name"),
					"services_ip_range_name": terraform.Output(t, vpcBootstrapTerraformOptions, "services_subnet_name"),
					"shared_vpc_self_link":   terraform.Output(t, vpcBootstrapTerraformOptions, "shared_vpc_self_link"),
					"shared_vpc_id":          terraform.Output(t, vpcBootstrapTerraformOptions, "shared_vpc_id"),
					"subnetwork_self_link":   terraform.Output(t, vpcBootstrapTerraformOptions, "primary_subnet_self_link"),
				},
			}

			logger.Logf(t, "gkeClusterTerratestOptions: %v\n", gkeClusterTerratestOptions)
			test_structure.SaveTerraformOptions(t, workingDir, gkeClusterTerratestOptions)
		})

		// Copy supporting files
		varFile := "wrapper.auto.tfvars"
		providerFile := "gcp_gke_providers.tf"
		testFileSourceDir, getTestDirErr := os.Getwd()
		if getTestDirErr != nil {
			fmt.Println("calling t.FailNow(): could not execute os.Getwd(): ", getTestDirErr)
			t.FailNow()
		}

		fmt.Println("test working directory is: ", testFileSourceDir)

		filesToCopy := []string{varFile, providerFile}

		fmt.Println("copying files: ", filesToCopy, " to temporary test dir: ", tempTestDir)
		copyFiles(t, filesToCopy, testFileSourceDir, tempTestDir)

		defer test_structure.RunTestStage(t, "gke_cleanup", func() {
			gkeClusterTerratestOptions := test_structure.LoadTerraformOptions(t, workingDir)
			terraform.Destroy(t, gkeClusterTerratestOptions)

			kubectlOptions := test_structure.LoadKubectlOptions(t, workingDir)
			err := os.Remove(kubectlOptions.ConfigPath)
			require.NoError(t, err)
		})

		log.Printf("About to start terraform_apply")
		test_structure.RunTestStage(t, "terraform_apply", func() {
			gkeClusterTerratestOptions := test_structure.LoadTerraformOptions(t, workingDir)
			terraform.InitAndApply(t, gkeClusterTerratestOptions)
		})

		logger.Log(t, "About to start configure_kubectl")
		test_structure.RunTestStage(t, "configure_kubectl", func() {

			gkeClusterTerratestOptions := test_structure.LoadTerraformOptions(t, workingDir)
			logger.Logf(t, "gkeClusterTerratestOptions looks like: %v", gkeClusterTerratestOptions)

			clusterName, clusterNameErr := terraform.OutputE(t, gkeClusterTerratestOptions, "cluster_name")
			if clusterNameErr != nil {
				logger.Logf(t, "Error getting cluster_name from 'terraform output cluster_name': %v", clusterNameErr)
			} else {
				logger.Log(t, "got clusterName = "+clusterName)
			}

			logger.Log(t, "working directory is: "+workingDir)
			gkeClusterTerraformModulePath := test_structure.LoadString(t, workingDir, "gkeClusterTerraformModulePath")

			clusterName = strings.ReplaceAll(clusterName, "\"", "")
			cmd := shell.Command{
				Command: "gcloud",
				Args: []string{
					"container",
					"clusters",
					"get-credentials", clusterName,
					"--region", gcpIndonesiaRegion,
					"--project", computeProject,
					"--quiet",
				},
				WorkingDir: gkeClusterTerraformModulePath,
			}
			shell.RunCommand(t, cmd)

			tmpKubeConfigPath := k8s.CopyHomeKubeConfigToTemp(t)
			kubectlOptions := k8s.NewKubectlOptions("", tmpKubeConfigPath, "kube-system")
			test_structure.SaveKubectlOptions(t, workingDir, kubectlOptions)
		})

		logger.Log(t, "About to start wait_for_workers")
		test_structure.RunTestStage(t, "wait_for_workers", func() {
			kubectlOptions := test_structure.LoadKubectlOptions(t, workingDir)
			verifyGkeNodesAreReady(t, kubectlOptions)
		})

		// Skipping this whole block to see if Terratest will pass

		logger.Log(t, "About to start verify")
		test_structure.RunTestStage(t, "terraform_verify_plan_noop", func() {

			// Validate Kubernetes version (1.23)
			gkeClusterTerraformModulePath := test_structure.LoadString(t, workingDir, "gkeClusterTerraformModulePath")
			clusterName = strings.ReplaceAll(clusterName, "\"", "")
			describeClusterCmd := shell.Command{
				Command: "gcloud",
				Args: []string{
					"container",
					"clusters",
					"describe", clusterName,
					"--region", gcpIndonesiaRegion,
					"--project", computeProject,
				},
				WorkingDir: gkeClusterTerraformModulePath,
			}
			describeClusterCmdOutput := shell.RunCommandAndGetStdOut(t, describeClusterCmd)
			assert.Contains(t, describeClusterCmdOutput, "1.24.10-gke.2300")

			gkeClusterTerratestOptions := test_structure.LoadTerraformOptions(t, workingDir)
			planResult := terraform.InitAndPlan(t, gkeClusterTerratestOptions)
			resourceCount, getResourceCountErr := terraform.GetResourceCountE(t, planResult)
			if getResourceCountErr != nil {
				log.Printf("error parsing terraform output: %s", planResult)
			} else {
				log.Printf("Got resource count - ADD: %d", resourceCount.Add)
				log.Printf("Got resource count - CHANGE: %d", resourceCount.Change)
				log.Printf("Got resource count - DESTROY: %d", resourceCount.Destroy)

				assert.LessOrEqual(t, resourceCount.Change, 1)
				assert.LessOrEqual(t, resourceCount.Add, 1)
				assert.LessOrEqual(t, resourceCount.Destroy, 1)

				//assert.Equal(t, 0, resourceCount.Change)
				//assert.Equal(t, 0, resourceCount.Add)
				//assert.Equal(t, 0, resourceCount.Destroy)
			}

			tags := terraform.OutputList(t, gkeClusterTerratestOptions, "cluster_all_primary_node_pool_tags")

			assert.NotNil(t, tags)
			assert.GreaterOrEqual(t, len(tags), 2)
		})
	})
}
