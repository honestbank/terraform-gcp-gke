package test

import (
	"strings"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func createTestGKEBasicHelmTerraformOptions(
	uniqueID,
	project string,
	region string,
	templatePath string,
	kubeConfigPath string,
) *terraform.Options {
	// gkeServiceAccountName := strings.ToLower(fmt.Sprintf("gke-cluster-sa-%s", uniqueID))

	terraformVars := map[string]interface{}{
		"region":   region,
		"location": region,
		"project":  project,
		// "cluster_service_account_name": gkeServiceAccountName + "@" + project + ".iam.gserviceaccount.com",
		"kubectl_config_path": kubeConfigPath,
	}

	terratestOptions := terraform.Options{
		TerraformDir: templatePath,
		Vars:         terraformVars,
	}

	return &terratestOptions
}

func createTestGKEClusterTerraformOptions(
	project string,
	region string,
	credentials string,
	templatePath string,
) *terraform.Options {

	terraformVars := map[string]interface{}{
		"region":             region,
		"project":            project,
		"google_credentials": credentials,
		"stage":        strings.ToLower(random.UniqueId()),
	}

	terratestOptions := terraform.Options{
		TerraformDir: templatePath,
		Vars:         terraformVars,
	}

	return &terratestOptions
}
