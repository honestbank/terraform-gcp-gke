package test

import (
	"strings"

	"github.com/gruntwork-io/terratest/modules/random"
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
		"stage":        "a"+strings.ToLower(random.UniqueId()), // Workaround for when uniqueId has a numerical prefix which GCP doesn't allow
	}

	terratestOptions := terraform.Options{
		TerraformDir: templatePath,
		Vars:         terraformVars,
	}

	return &terratestOptions
}
