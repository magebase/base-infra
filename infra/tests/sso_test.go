package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestSSOInfrastructure runs the SSO infrastructure tests
func TestSSOInfrastructure(t *testing.T) {
	t.Parallel()

	// Get test configuration
	testConfig := getTestConfig()

	// Run the SSO setup test
	testSSOSetup(t, testConfig)
}

// testSSOSetup tests AWS Organizations and SSO setup
func testSSOSetup(t *testing.T, config *TestConfig) {
	t.Log("🔐 Testing AWS Organizations & SSO Setup")

	// Get test configuration
	testConfig := getTestConfig()

	// Validate required environment variables
	requireEnvironmentVariables(t, []string{
		"AWS_ACCESS_KEY_ID",
		"AWS_SECRET_ACCESS_KEY",
		"MANAGEMENT_ACCOUNT_ID",
	})

	// Validate Terraform code
	validateTerraformCode(t, testConfig.OrgSSODir)

	// Setup Terraform options
	terraformOptions := setupTerraformOptions(t, testConfig.OrgSSODir, map[string]interface{}{
		"environment":  config.Environment,
		"project_name": config.ProjectName,
	})

	// Ensure cleanup on failure
	defer cleanupTestResources(t, terraformOptions)

	// Test Terraform Init
	t.Run("TerraformInit", func(t *testing.T) {
		terraform.Init(t, terraformOptions)
	})

	// Test Terraform Validate
	t.Run("TerraformValidate", func(t *testing.T) {
		terraform.Validate(t, terraformOptions)
	})

	// Test Terraform Plan
	t.Run("TerraformPlan", func(t *testing.T) {
		terraform.Plan(t, terraformOptions)
	})

	// Test Terraform Apply
	t.Run("TerraformApply", func(t *testing.T) {
		terraform.Apply(t, terraformOptions)
	})

	// Test AWS Organization
	t.Run("AWSOrganization", func(t *testing.T) {
		testAWSOrganization(t, terraformOptions, config)
	})

	// Test AWS Accounts
	t.Run("AWSAccounts", func(t *testing.T) {
		testAWSAccounts(t, terraformOptions, config)
	})

	// Test AWS SSO
	t.Run("AWSSSO", func(t *testing.T) {
		testAWSSSO(t, terraformOptions, config)
	})

	// Test Permission Sets
	t.Run("PermissionSets", func(t *testing.T) {
		testPermissionSets(t, terraformOptions, config)
	})

	// Test Account Assignments
	t.Run("AccountAssignments", func(t *testing.T) {
		testAccountAssignments(t, terraformOptions, config)
	})

	// Test Terraform Outputs
	t.Run("TerraformOutputs", func(t *testing.T) {
		testSSOOutputs(t, terraformOptions)
	})
}

// testSSOOutputs validates Terraform outputs
func testSSOOutputs(t *testing.T, terraformOptions *terraform.Options) {
	t.Log("📤 Testing SSO Terraform Outputs")

	// Check development account ID output
	devAccountId := terraform.Output(t, terraformOptions, "development_account_id")
	assert.NotEmpty(t, devAccountId, "development_account_id output should not be empty")

	// Check production account ID output
	prodAccountId := terraform.Output(t, terraformOptions, "production_account_id")
	assert.NotEmpty(t, prodAccountId, "production_account_id output should not be empty")

	t.Logf("✅ SSO outputs validated: dev=%s, prod=%s", devAccountId, prodAccountId)
}

// testAWSOrganization validates AWS Organization setup
func testAWSOrganization(t *testing.T, terraformOptions *terraform.Options, config *TestConfig) {
	t.Log("🏢 Testing AWS Organization Setup")

	// Get organization details from Terraform outputs
	orgId := terraform.Output(t, terraformOptions, "organization_id")
	assert.NotEmpty(t, orgId, "Organization ID should not be empty")

	orgArn := terraform.Output(t, terraformOptions, "organization_arn")
	assert.NotEmpty(t, orgArn, "Organization ARN should not be empty")
	assert.Contains(t, orgArn, "organizations/", "Organization ARN should contain organizations path")

	orgMasterAccountId := terraform.Output(t, terraformOptions, "organization_master_account_id")
	assert.NotEmpty(t, orgMasterAccountId, "Organization master account ID should not be empty")

	t.Logf("✅ AWS Organization validated: ID=%s", orgId)
}

// testAWSAccounts validates AWS account creation
func testAWSAccounts(t *testing.T, terraformOptions *terraform.Options, config *TestConfig) {
	t.Log("👥 Testing AWS Account Creation")

	// Get account IDs from Terraform outputs
	devAccountId := terraform.Output(t, terraformOptions, "development_account_id")
	assert.NotEmpty(t, devAccountId, "Development account ID should not be empty")

	prodAccountId := terraform.Output(t, terraformOptions, "production_account_id")
	assert.NotEmpty(t, prodAccountId, "Production account ID should not be empty")

	// Validate account details
	devAccountEmail := terraform.Output(t, terraformOptions, "development_account_email")
	assert.NotEmpty(t, devAccountEmail, "Development account email should not be empty")
	assert.Contains(t, devAccountEmail, "@", "Development account email should be valid")

	prodAccountEmail := terraform.Output(t, terraformOptions, "production_account_email")
	assert.NotEmpty(t, prodAccountEmail, "Production account email should not be empty")
	assert.Contains(t, prodAccountEmail, "@", "Production account email should be valid")

	t.Logf("✅ AWS Accounts validated: Dev=%s, Prod=%s", devAccountId, prodAccountId)
}

// testAWSSSO validates AWS SSO setup
func testAWSSSO(t *testing.T, terraformOptions *terraform.Options, config *TestConfig) {
	t.Log("🔑 Testing AWS SSO Setup")

	// Get SSO instance details from Terraform outputs
	ssoInstanceArn := terraform.Output(t, terraformOptions, "sso_instance_arn")
	assert.NotEmpty(t, ssoInstanceArn, "SSO instance ARN should not be empty")
	assert.Contains(t, ssoInstanceArn, "sso", "SSO instance ARN should contain 'sso'")

	identityStoreId := terraform.Output(t, terraformOptions, "identity_store_id")
	assert.NotEmpty(t, identityStoreId, "Identity Store ID should not be empty")

	ssoInstanceStatus := terraform.Output(t, terraformOptions, "sso_instance_status")
	assert.Equal(t, "ACTIVE", ssoInstanceStatus, "SSO instance should be active")

	t.Logf("✅ AWS SSO validated: %s", ssoInstanceArn)
}

// testPermissionSets validates SSO permission sets
func testPermissionSets(t *testing.T, terraformOptions *terraform.Options, config *TestConfig) {
	t.Log("📋 Testing SSO Permission Sets")

	// Get permission set details from Terraform outputs
	adminPermissionSetArn := terraform.Output(t, terraformOptions, "admin_permission_set_arn")
	assert.NotEmpty(t, adminPermissionSetArn, "Admin permission set ARN should not be empty")

	devPermissionSetArn := terraform.Output(t, terraformOptions, "developer_permission_set_arn")
	assert.NotEmpty(t, devPermissionSetArn, "Developer permission set ARN should not be empty")

	// Validate permission set names
	adminPermissionSetName := terraform.Output(t, terraformOptions, "admin_permission_set_name")
	assert.Equal(t, "AdministratorAccess", adminPermissionSetName, "Admin permission set should have correct name")

	devPermissionSetName := terraform.Output(t, terraformOptions, "developer_permission_set_name")
	assert.Equal(t, "DeveloperAccess", devPermissionSetName, "Developer permission set should have correct name")

	t.Logf("✅ Permission sets validated: Admin=%s, Dev=%s", adminPermissionSetArn, devPermissionSetArn)
}

// testAccountAssignments validates SSO account assignments
func testAccountAssignments(t *testing.T, terraformOptions *terraform.Options, config *TestConfig) {
	t.Log("👤 Testing SSO Account Assignments")

	// Get assignment details from Terraform outputs
	devAccountAssignments := terraform.Output(t, terraformOptions, "development_account_assignments")
	assert.NotEmpty(t, devAccountAssignments, "Development account assignments should not be empty")

	prodAccountAssignments := terraform.Output(t, terraformOptions, "production_account_assignments")
	assert.NotEmpty(t, prodAccountAssignments, "Production account assignments should not be empty")

	// Validate assignment counts
	devAssignmentCount := terraform.Output(t, terraformOptions, "development_assignment_count")
	assert.Equal(t, "2", devAssignmentCount, "Development account should have 2 assignments (admin + dev)")

	prodAssignmentCount := terraform.Output(t, terraformOptions, "production_assignment_count")
	assert.Equal(t, "1", prodAssignmentCount, "Production account should have 1 assignment (admin only)")

	t.Log("✅ Account assignments validated")
}
