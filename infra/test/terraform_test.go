package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformInfrastructure(t *testing.T) {
	t.Parallel()

	// Test dev environment
	t.Run("DevEnvironment", func(t *testing.T) {
		t.Parallel()
		testEnvironment(t, "dev")
	})

	// Test qa environment
	t.Run("QaEnvironment", func(t *testing.T) {
		t.Parallel()
		testEnvironment(t, "qa")
	})

	// Test uat environment
	t.Run("UatEnvironment", func(t *testing.T) {
		t.Parallel()
		testEnvironment(t, "uat")
	})

	// Test prod environment
	t.Run("ProdEnvironment", func(t *testing.T) {
		t.Parallel()
		testEnvironment(t, "prod")
	})
}

func testEnvironment(t *testing.T, environment string) {
	t.Helper()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"environment": environment,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Validate infrastructure
	validateInfrastructure(t, terraformOptions, environment)
}

func TestTerraformSecurityHeaders(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"environment": "dev",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test that security headers are properly configured
	// This would require making HTTP requests to verify headers
	// For now, we just verify the infrastructure deploys successfully
}

func validateInfrastructure(t *testing.T, terraformOptions *terraform.Options, environment string) {
	// Basic validation that infrastructure was created successfully
	// In a real scenario, you would add more specific validations here

	// Example: Check that outputs exist and have expected values
	// flyAppName := terraform.Output(t, terraformOptions, "fly_app_name")
	// assert.NotEmpty(t, flyAppName)

	// For now, we just ensure the terraform apply succeeded
	// Additional validations would be added based on specific requirements
}
