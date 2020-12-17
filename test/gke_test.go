package test

import (
	"log"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTerraformGcpGkeTemplate(t *testing.T) {

	testCaseName := "gke_test"
	// Create all resources in the following zone
	gcpIndonesiaRegion := "asia-southeast2"

	t.Run(testCaseName, func(t *testing.T) {
		t.Parallel()

		// Create a directory path that won't conflict
		workingDir := filepath.Join(".", "test-runs", testCaseName)

		test_structure.RunTestStage(t, "create_test_copy", func() {
			testFolder := test_structure.CopyTerraformFolderToTemp(t, "../gcp-gke", ".")
			logger.Logf(t, "path to test folder %s\n", testFolder)
			test_structure.SaveString(t, workingDir, "gkeClusterTerraformModulePath", testFolder)
		})

		test_structure.RunTestStage(t, "create_terratest_options", func() {
			gkeClusterTerraformModulePath := test_structure.LoadString(t, workingDir, "gkeClusterTerraformModulePath")

			// On a blank docker image:
			// - install go (and gcc)
			// - install git
			// - download terraform
			// make sure to `export`:
			// GOOGLE_PROJECT=test-terraform-project-01
			// GOOGLE_CREDENTIALS=service account for GOOGLE_PROJECT
			// TF_VAR_shared_vpc_host_google_project="test-gcp-project-01-274314"
			// TF_VAR_shared_vpc_host_google_credentials=service account for shared_vpc_host_google_project
			project := gcp.GetGoogleProjectIDFromEnvVar(t)
			credentials := gcp.GetGoogleCredentialsFromEnvVar(t)
			region := gcpIndonesiaRegion
			gkeClusterTerratestOptions := createTestGKEClusterTerraformOptions(
				project,
				region,
				credentials,
				gkeClusterTerraformModulePath)

			// if testCase.overrideDefaultSA {
			// 	gkeClusterTerratestOptions.Vars["override_default_node_pool_service_account"] = "1"
			// }

			logger.Logf(t, "gkeClusterTerratestOptions: %v\n", gkeClusterTerratestOptions)
			test_structure.SaveString(t, workingDir, "project", project)
			test_structure.SaveString(t, workingDir, "region", region)
			test_structure.SaveTerraformOptions(t, workingDir, gkeClusterTerratestOptions)
		})

		defer test_structure.RunTestStage(t, "cleanup", func() {
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

			project := test_structure.LoadString(t, workingDir, "project")
			logger.Log(t, "got project = "+project)

			region := test_structure.LoadString(t, workingDir, "region")
			logger.Log(t, "got region = "+region)

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
					"--region", region,
					"--project", project,
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

		logger.Log(t, "About to start terraform_verify_plan_noop")
		test_structure.RunTestStage(t, "terraform_verify_plan_noop", func() {
			gkeClusterTerratestOptions := test_structure.LoadTerraformOptions(t, workingDir)
			planResult := terraform.InitAndPlan(t, gkeClusterTerratestOptions)
			resourceCount := terraform.GetResourceCount(t, planResult)
			assert.Equal(t, 0, resourceCount.Change)
			assert.Equal(t, 0, resourceCount.Add)
			assert.Equal(t, 0, resourceCount.Destroy)
		})
	})
}
