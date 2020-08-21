package test

import (
	"regexp"
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
		"stage":        alphaPrefixUniqueId,
	}

	terratestOptions := terraform.Options{
		TerraformDir: templatePath,
		Vars:         terraformVars,
	}

	return &terratestOptions
}

func alphaPrefixUniqueId() string {
	uniqueId := strings.ToLower(random.UniqueId())
	hasNumericalPrefix, _ := regexp.MatchString(`^[0-9][a-zA-Z0-9]*`, uniqueId)
	for hasNumericalPrefix == true {
		uniqueId = random.UniqueId()
		hasNumericalPrefix, _ = regexp.MatchString(`^[0-9][a-zA-Z0-9]*`, uniqueId)
	}
	return uniqueId
}
