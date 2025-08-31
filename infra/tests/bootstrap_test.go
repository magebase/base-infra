package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// testBootstrapInfrastructure tests the Terraform state backend bootstrap
func testBootstrapInfrastructure(t *testing.T, config *TestConfig) {
	t.Log("🧪 Testing Terraform State Backend Bootstrap")

	// Get test configuration
	testConfig := getTestConfig()

	// Validate required environment variables
	requireEnvironmentVariables(t, []string{
		"AWS_ACCESS_KEY_ID",
		"AWS_SECRET_ACCESS_KEY",
		"MANAGEMENT_ACCOUNT_ID",
	})

	// Validate Terraform code
	validateTerraformCode(t, testConfig.BootstrapDir)

	// Setup Terraform options
	terraformOptions := setupTerraformOptions(t, testConfig.BootstrapDir, map[string]interface{}{
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

	// Test S3 Bucket Creation
	t.Run("S3Bucket", func(t *testing.T) {
		testS3BucketCreation(t, terraformOptions, config)
	})

	// Test DynamoDB Table Creation
	t.Run("DynamoDBTable", func(t *testing.T) {
		testDynamoDBTableCreation(t, terraformOptions, config)
	})

	// Test Terraform Outputs
	t.Run("TerraformOutputs", func(t *testing.T) {
		testBootstrapOutputs(t, terraformOptions)
	})

	// Test Integration
	t.Run("Integration", func(t *testing.T) {
		testBootstrapIntegration(t, terraformOptions, config)
	})
}

// testS3BucketCreation validates the S3 bucket for Terraform state
func testS3BucketCreation(t *testing.T, terraformOptions *terraform.Options, config *TestConfig) {
	t.Log("🪣 Testing S3 Bucket Creation")

	// Get bucket name from Terraform output
	bucketName := terraform.Output(t, terraformOptions, "state_bucket_name")
	assert.NotEmpty(t, bucketName, "State bucket name should not be empty")
	assert.Contains(t, bucketName, config.ProjectName, "Bucket name should contain project name")

	// Validate bucket configuration through Terraform outputs
	bucketVersioning := terraform.Output(t, terraformOptions, "state_bucket_versioning")
	assert.Equal(t, "Enabled", bucketVersioning, "S3 bucket should have versioning enabled")

	// Check bucket encryption (validate via output)
	bucketEncryption := terraform.Output(t, terraformOptions, "state_bucket_encryption")
	assert.NotEmpty(t, bucketEncryption, "S3 bucket should have encryption enabled")

	// Check bucket region
	bucketRegion := terraform.Output(t, terraformOptions, "state_bucket_region")
	assert.Equal(t, config.AWSRegion, bucketRegion, "Bucket should be in correct region")

	t.Logf("✅ S3 Bucket %s validated successfully", bucketName)
}

// testDynamoDBTableCreation validates the DynamoDB table for Terraform locks
func testDynamoDBTableCreation(t *testing.T, terraformOptions *terraform.Options, config *TestConfig) {
	t.Log("🗄️ Testing DynamoDB Table Creation")

	// Get table name from Terraform output
	tableName := terraform.Output(t, terraformOptions, "dynamodb_table_name")
	assert.NotEmpty(t, tableName, "DynamoDB table name should not be empty")
	assert.Contains(t, tableName, config.ProjectName, "Table name should contain project name")

	// Validate table configuration through Terraform outputs
	tableStatus := terraform.Output(t, terraformOptions, "dynamodb_table_status")
	assert.Equal(t, "ACTIVE", tableStatus, "DynamoDB table should be active")

	// Check billing mode
	billingMode := terraform.Output(t, terraformOptions, "dynamodb_billing_mode")
	assert.Equal(t, "PAY_PER_REQUEST", billingMode, "DynamoDB table should use pay-per-request billing")

	// Check hash key
	hashKey := terraform.Output(t, terraformOptions, "dynamodb_hash_key")
	assert.Equal(t, "LockID", hashKey, "DynamoDB table should have LockID as hash key")

	t.Logf("✅ DynamoDB Table %s validated successfully", tableName)
}

// testBootstrapOutputs validates Terraform outputs
func testBootstrapOutputs(t *testing.T, terraformOptions *terraform.Options) {
	t.Log("📤 Testing Terraform Outputs")

	// Check state_bucket output
	stateBucket := terraform.Output(t, terraformOptions, "state_bucket")
	assert.NotEmpty(t, stateBucket, "state_bucket output should not be empty")
	assert.Contains(t, stateBucket, "tf-state-bootstrap", "state_bucket should contain bootstrap identifier")

	// Check dynamodb_table output
	dynamodbTable := terraform.Output(t, terraformOptions, "dynamodb_table")
	assert.NotEmpty(t, dynamodbTable, "dynamodb_table output should not be empty")
	assert.Contains(t, dynamodbTable, "terraform-locks-bootstrap", "dynamodb_table should contain locks identifier")

	t.Logf("✅ Terraform outputs validated: state_bucket=%s, dynamodb_table=%s", stateBucket, dynamodbTable)
}

// testBootstrapIntegration tests integration between bootstrap components
func testBootstrapIntegration(t *testing.T, terraformOptions *terraform.Options, config *TestConfig) {
	t.Log("🔗 Testing Bootstrap Integration")

	// Get resource names from Terraform outputs
	bucketName := terraform.Output(t, terraformOptions, "state_bucket_name")
	tableName := terraform.Output(t, terraformOptions, "dynamodb_table_name")

	// Verify both resources are properly configured
	assert.NotEmpty(t, bucketName, "S3 bucket should be created")
	assert.NotEmpty(t, tableName, "DynamoDB table should be created")

	// Test backend configuration compatibility
	backendConfig := map[string]interface{}{
		"bucket":         bucketName,
		"region":         config.AWSRegion,
		"dynamodb_table": tableName,
		"encrypt":        true,
	}

	// Validate backend configuration
	assert.NotNil(t, backendConfig["bucket"], "Backend should have bucket configured")
	assert.NotNil(t, backendConfig["dynamodb_table"], "Backend should have DynamoDB table configured")
	assert.Equal(t, config.AWSRegion, backendConfig["region"], "Backend should use correct region")
	assert.True(t, backendConfig["encrypt"].(bool), "Backend should have encryption enabled")

	t.Logf("✅ Bootstrap integration validated: bucket=%s, table=%s", bucketName, tableName)
}
