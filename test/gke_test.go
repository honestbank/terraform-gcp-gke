package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTerraformGcpExample(t *testing.T) {

	testCaseName := "gke_test"

	// Create all resources in the following zone
	gcpIndonesiaRegion := "asia-southeast2"

	t.Run(testCaseName, func(t *testing.T) {
		t.Parallel()

		// Create a directory path that won't conflict
		workingDir := filepath.Join(".", "test-runs", testCaseName)

		// OK
		test_structure.RunTestStage(t, "create_test_copy", func() {
			testFolder := test_structure.CopyTerraformFolderToTemp(t, "../gcp-gke", ".")
			logger.Logf(t, "path to test folder %s\n", testFolder)
			test_structure.SaveString(t, workingDir, "gkeClusterTerraformModulePath", testFolder)
		})

		// WIP
		test_structure.RunTestStage(t, "create_terratest_options", func() {
			gkeClusterTerraformModulePath := test_structure.LoadString(t, workingDir, "gkeClusterTerraformModulePath")
			tmpKubeConfigPath := k8s.CopyHomeKubeConfigToTemp(t)
			kubectlOptions := k8s.NewKubectlOptions("", tmpKubeConfigPath, "kube-system")
			uniqueID := random.UniqueId()

			// make sure to `export` one of these vars
			// GOOGLE_PROJECT GOOGLE_CLOUD_PROJECT GOOGLE_CLOUD_PROJECT_ID
			// GCLOUD_PROJECT CLOUDSDK_CORE_PROJECT
			project := gcp.GetGoogleProjectIDFromEnvVar(t)
			region := gcpIndonesiaRegion
			gkeClusterTerratestOptions := createTestGKEClusterTerraformOptions(
				uniqueID,
				project,
				region,
				gkeClusterTerraformModulePath)

			// if testCase.overrideDefaultSA {
			// 	gkeClusterTerratestOptions.Vars["override_default_node_pool_service_account"] = "1"
			// }

			logger.Logf(t, "gkeClusterTerratestOptions: %v\n", gkeClusterTerratestOptions)
			test_structure.SaveString(t, workingDir, "uniqueID", uniqueID)
			test_structure.SaveString(t, workingDir, "project", project)
			test_structure.SaveString(t, workingDir, "region", region)
			test_structure.SaveTerraformOptions(t, workingDir, gkeClusterTerratestOptions)
			test_structure.SaveKubectlOptions(t, workingDir, kubectlOptions)
		})

		defer test_structure.RunTestStage(t, "cleanup", func() {
			gkeClusterTerratestOptions := test_structure.LoadTerraformOptions(t, workingDir)
			terraform.Destroy(t, gkeClusterTerratestOptions)

			kubectlOptions := test_structure.LoadKubectlOptions(t, workingDir)
			err := os.Remove(kubectlOptions.ConfigPath)
			require.NoError(t, err)
		})

		test_structure.RunTestStage(t, "terraform_apply", func() {
			gkeClusterTerratestOptions := test_structure.LoadTerraformOptions(t, workingDir)
			terraform.InitAndApply(t, gkeClusterTerratestOptions)
		})

		test_structure.RunTestStage(t, "configure_kubectl", func() {
			gkeClusterTerratestOptions := test_structure.LoadTerraformOptions(t, workingDir)
			kubectlOptions := test_structure.LoadKubectlOptions(t, workingDir)
			project := test_structure.LoadString(t, workingDir, "project")
			region := test_structure.LoadString(t, workingDir, "region")
			clusterName := gkeClusterTerratestOptions.Vars["cluster_name"].(string)

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
				Env: map[string]string{
					"KUBECONFIG": kubectlOptions.ConfigPath,
				},
			}
			shell.RunCommand(t, cmd)
		})

		test_structure.RunTestStage(t, "wait_for_workers", func() {
			kubectlOptions := test_structure.LoadKubectlOptions(t, workingDir)
			verifyGkeNodesAreReady(t, kubectlOptions)
		})

		test_structure.RunTestStage(t, "terraform_verify_plan_noop", func() {
			gkeClusterTerratestOptions := test_structure.LoadTerraformOptions(t, workingDir)
			planResult := terraform.InitAndPlan(t, gkeClusterTerratestOptions)
			resourceCount := terraform.GetResourceCount(t, planResult)
			assert.Equal(t, 0, resourceCount.Change)
			assert.Equal(t, 0, resourceCount.Add)
		})

		test_structure.RunTestStage(t, "verify_istio", func() {
			kubectlOptions := test_structure.LoadKubectlOptions(t, workingDir)

			_, istioOperatorNamespaceError := k8s.GetNamespaceE(t, kubectlOptions, "istio-operator")
			assert.Nil(t, istioOperatorNamespaceError, "Could not find istio-operator namespace")

			_, istioSystemNamespaceError := k8s.GetNamespaceE(t, kubectlOptions, "istio-system")
			assert.Nil(t, istioSystemNamespaceError, "Could not find istio-system namespace")
		})

		test_structure.RunTestStage(t, "verify_kiali", func() {
			kubectlOptions := test_structure.LoadKubectlOptions(t, workingDir)

			_, kialiPodError := k8s.GetPodE(t, kubectlOptions, "kiali")
			assert.Nil(t, kialiPodError, "Could not find a Pod named 'kiali'")
		})
	})
}
