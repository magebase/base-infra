package test

import (
	"os"
	"testing"
)

// Test constants
const (
	ProjectName         = "magebase"
	Environment         = "test"
	AWSRegion           = "ap-southeast-1"
	SSORegion           = "ap-southeast-1"
	ManagementAccountID = "123456789012" // Replace with actual management account ID
)

// TestMain sets up the test environment
func TestMain(m *testing.M) {
	// Set test environment variables
	os.Setenv("TF_VAR_environment", Environment)
	os.Setenv("AWS_REGION", AWSRegion)
	os.Setenv("AWS_DEFAULT_REGION", AWSRegion)

	// Run tests
	code := m.Run()

	// Cleanup if needed
	os.Exit(code)
}

// TestUnifiedInfrastructure runs the complete infrastructure test suite
func TestUnifiedInfrastructure(t *testing.T) {
	t.Parallel()

	// Test configuration
	testConfig := &TestConfig{
		Environment: Environment,
		AWSRegion:   AWSRegion,
		SSORegion:   SSORegion,
		ProjectName: ProjectName,
	}

	// Run bootstrap tests first (must be sequential)
	t.Run("Bootstrap", func(t *testing.T) {
		testBootstrapInfrastructure(t, testConfig)
	})

	// Run SSO tests (depends on bootstrap)
	t.Run("SSO", func(t *testing.T) {
		testSSOSetup(t, testConfig)
	})

	// Run base infrastructure tests (depends on bootstrap and SSO)
	t.Run("BaseInfrastructure", func(t *testing.T) {
		testBaseInfrastructure(t, testConfig)
	})

	// Run integration tests
	t.Run("Integration", func(t *testing.T) {
		testIntegration(t, testConfig)
	})
}
