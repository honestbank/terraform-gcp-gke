package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func createTestGKEClusterTerraformOptions(
	project string,
	region string,
	credentials string,
	templatePath string,
) *terraform.Options {

	terraformVars := map[string]interface{}{
		"google_region":             region,
		"google_project":            project,
		"google_credentials": credentials,
		"stage": "test",
	}

	terratestOptions := terraform.Options{
		TerraformDir: templatePath,
		Vars:         terraformVars,
	}

	return &terratestOptions
}
