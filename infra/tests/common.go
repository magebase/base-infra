package test

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestConfig holds test configuration
type TestConfig struct {
	Environment         string
	AWSRegion          string
	SSORegion          string
	ProjectName        string
	BootstrapDir       string
	OrgSSODir          string
	BaseInfrastructureDir string
}

// getTestConfig returns the test configuration with proper paths
func getTestConfig() *TestConfig {
	wd, _ := os.Getwd()
	projectRoot := filepath.Join(wd, "..", "..")

	return &TestConfig{
		Environment:           "test",
		AWSRegion:            "ap-southeast-1",
		SSORegion:            "ap-southeast-1",
		ProjectName:          "magebase",
		BootstrapDir:         filepath.Join(projectRoot, "pipeline", "bootstrap"),
		OrgSSODir:           filepath.Join(projectRoot, "pipeline", "org-sso"),
		BaseInfrastructureDir: filepath.Join(projectRoot, "pipeline", "base-infrastructure"),
	}
}

// requireEnvironmentVariables checks for required environment variables
func requireEnvironmentVariables(t *testing.T, vars []string) {
	for _, v := range vars {
		require.NotEmpty(t, os.Getenv(v), fmt.Sprintf("Environment variable %s must be set", v))
	}
}

// validateTerraformCode runs basic validation on Terraform code
func validateTerraformCode(t *testing.T, terraformDir string) {
	// Check if directory exists
	require.DirExists(t, terraformDir, "Terraform directory should exist")

	// Check for required files
	requiredFiles := []string{
		"main.tf",
		"variables.tf",
	}

	for _, file := range requiredFiles {
		filePath := filepath.Join(terraformDir, file)
		require.FileExists(t, filePath, fmt.Sprintf("%s should exist", file))
	}
}

// setupTerraformOptions creates Terraform options for a given directory
func setupTerraformOptions(t *testing.T, terraformDir string, vars map[string]interface{}) *terraform.Options {
	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Vars:         vars,
		BackendConfig: map[string]interface{}{
			"bucket":         fmt.Sprintf("magebase-tf-state-bootstrap-ap-southeast-1"),
			"region":         "ap-southeast-1",
			"dynamodb_table": fmt.Sprintf("magebase-terraform-locks-bootstrap"),
			"encrypt":        true,
		},
		RetryableTerraformErrors: map[string]string{
			".*timeout while waiting for state to become.*": "Temporary state timeout",
			".*Lock Info.*":                                "State lock conflict",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 30, // seconds
	}

	// Set AWS credentials if available
	if accessKey := os.Getenv("AWS_ACCESS_KEY_ID"); accessKey != "" {
		terraformOptions.EnvVars = map[string]string{
			"AWS_ACCESS_KEY_ID":     accessKey,
			"AWS_SECRET_ACCESS_KEY": os.Getenv("AWS_SECRET_ACCESS_KEY"),
			"AWS_REGION":           "ap-southeast-1",
			"AWS_DEFAULT_REGION":   "ap-southeast-1",
		}
	}

	return terraformOptions
}

// cleanupTestResources cleans up test resources
func cleanupTestResources(t *testing.T, terraformOptions *terraform.Options) {
	// Note: In a real implementation, you might want to destroy resources
	// But for now, we'll just log that cleanup would happen
	t.Log("🧹 Test cleanup would destroy resources here")
}
