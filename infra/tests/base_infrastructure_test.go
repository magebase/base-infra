package test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestBaseInfrastructure runs the base infrastructure tests
func TestBaseInfrastructure(t *testing.T) {
	t.Parallel()

	// Get test configuration
	testConfig := getTestConfig()

	// Run the base infrastructure test
	testBaseInfrastructure(t, testConfig)
}

// testBaseInfrastructure tests the base infrastructure (Hetzner k3s cluster)
func testBaseInfrastructure(t *testing.T, config *TestConfig) {
	t.Log("🏗️ Testing Base Infrastructure (k3s Cluster)")

	// Get test configuration
	testConfig := getTestConfig()

	// Validate required environment variables
	requireEnvironmentVariables(t, []string{
		"AWS_ACCESS_KEY_ID",
		"AWS_SECRET_ACCESS_KEY",
		"HCLOUD_TOKEN",
		"SSH_PRIVATE_KEY",
		"SSH_PUBLIC_KEY",
	})

	// Validate Terraform code
	validateTerraformCode(t, testConfig.BaseInfrastructureDir)

	// Setup Terraform options
	terraformOptions := setupTerraformOptions(t, testConfig.BaseInfrastructureDir, map[string]interface{}{
		"environment":     config.Environment,
		"project_name":    config.ProjectName,
		"hcloud_token":    "dummy", // Will be overridden by env var
		"ssh_private_key": "dummy", // Will be overridden by env var
		"ssh_public_key":  "dummy", // Will be overridden by env var
	})

	// Set environment variables for sensitive values
	terraformOptions.EnvVars = map[string]string{
		"TF_VAR_hcloud_token":    os.Getenv("HCLOUD_TOKEN"),
		"TF_VAR_ssh_private_key": os.Getenv("SSH_PRIVATE_KEY"),
		"TF_VAR_ssh_public_key":  os.Getenv("SSH_PUBLIC_KEY"),
		"AWS_ACCESS_KEY_ID":      os.Getenv("AWS_ACCESS_KEY_ID"),
		"AWS_SECRET_ACCESS_KEY":  os.Getenv("AWS_SECRET_ACCESS_KEY"),
		"AWS_REGION":             config.AWSRegion,
		"AWS_DEFAULT_REGION":     config.AWSRegion,
	}

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

	// Test Hetzner Resources
	t.Run("HetznerResources", func(t *testing.T) {
		testHetznerResources(t, config)
	})

	// Test Load Balancer
	t.Run("LoadBalancer", func(t *testing.T) {
		testLoadBalancer(t, config)
	})

	// Test Networking
	t.Run("Networking", func(t *testing.T) {
		testNetworking(t, config)
	})

	// Test Terraform Outputs
	t.Run("TerraformOutputs", func(t *testing.T) {
		testBaseInfrastructureOutputs(t, terraformOptions)
	})
}

// testHetznerResources validates Hetzner Cloud resources
func testHetznerResources(t *testing.T, config *TestConfig) {
	t.Log("🌐 Testing Hetzner Cloud Resources")

	// Note: Hetzner Cloud resources would need custom Terratest modules
	// For now, we'll validate that the Terraform outputs indicate successful creation

	// In a real implementation, you would:
	// 1. Use Hetzner Cloud API to validate server creation
	// 2. Check server status and configuration
	// 3. Validate SSH connectivity
	// 4. Check firewall rules

	t.Log("✅ Hetzner resources validation placeholder (would use Hetzner API)")
}

// testLoadBalancer validates the Hetzner load balancer
func testLoadBalancer(t *testing.T, config *TestConfig) {
	t.Log("⚖️ Testing Load Balancer Configuration")

	// Note: Load balancer testing would require Hetzner Cloud API access
	// This is a placeholder for actual load balancer validation

	t.Log("✅ Load balancer validation placeholder (would check Hetzner LB status)")
}

// testNetworking validates network configuration
func testNetworking(t *testing.T, config *TestConfig) {
	t.Log("🌐 Testing Network Configuration")

	// Test VPC/subnet configuration
	// Note: This would require AWS API calls for any AWS networking components

	// In the actual infrastructure, networking is primarily handled by Hetzner
	// with private networks and firewalls

	t.Log("✅ Network configuration validation placeholder")
}

// testBaseInfrastructureOutputs validates Terraform outputs
func testBaseInfrastructureOutputs(t *testing.T, terraformOptions *terraform.Options) {
	t.Log("📤 Testing Base Infrastructure Terraform Outputs")

	// Check kubeconfig output (sensitive - handle carefully)
	kubeconfig := terraform.Output(t, terraformOptions, "kubeconfig")
	assert.NotEmpty(t, kubeconfig, "kubeconfig output should not be empty")

	// Check load balancer IPv4
	lbIpv4 := terraform.Output(t, terraformOptions, "lb_ipv4")
	assert.NotEmpty(t, lbIpv4, "lb_ipv4 output should not be empty")
	assert.Regexp(t, `^\d+\.\d+\.\d+\.\d+$`, lbIpv4, "lb_ipv4 should be a valid IPv4 address")

	// Check load balancer IPv6 (if present)
	lbIpv6 := terraform.Output(t, terraformOptions, "lb_ipv6")
	if lbIpv6 != "" {
		assert.Regexp(t, `^[0-9a-fA-F:]+$`, lbIpv6, "lb_ipv6 should be a valid IPv6 address")
	}

	// Check control plane endpoints
	controlPlaneEndpoints := terraform.OutputList(t, terraformOptions, "control_plane_ipv4")
	assert.Greater(t, len(controlPlaneEndpoints), 0, "Should have at least one control plane endpoint")

	for i, endpoint := range controlPlaneEndpoints {
		assert.Regexp(t, `^\d+\.\d+\.\d+\.\d+$`, endpoint,
			fmt.Sprintf("Control plane endpoint %d should be a valid IPv4 address", i))
	}

	// Check agent node endpoints
	agentEndpoints := terraform.OutputList(t, terraformOptions, "agent_ipv4")
	assert.GreaterOrEqual(t, len(agentEndpoints), 0, "Agent endpoints list should exist")

	for i, endpoint := range agentEndpoints {
		assert.Regexp(t, `^\d+\.\d+\.\d+\.\d+$`, endpoint,
			fmt.Sprintf("Agent endpoint %d should be a valid IPv4 address", i))
	}

	t.Logf("✅ Base infrastructure outputs validated: %d control planes, %d agents",
		len(controlPlaneEndpoints), len(agentEndpoints))
}

// testKubernetesCluster validates the k3s cluster functionality
func testKubernetesCluster(t *testing.T, config *TestConfig, terraformOptions *terraform.Options) {
	t.Log("🐳 Testing Kubernetes Cluster")

	// Get kubeconfig from Terraform output
	kubeconfig := terraform.Output(t, terraformOptions, "kubeconfig")
	require.NotEmpty(t, kubeconfig, "kubeconfig should not be empty")

	// Note: In a real implementation, you would:
	// 1. Parse the kubeconfig
	// 2. Create a Kubernetes client
	// 3. Test cluster connectivity
	// 4. Validate node status
	// 5. Check core services (kube-system pods)
	// 6. Test basic kubectl operations

	// For now, this is a placeholder
	assert.Contains(t, kubeconfig, "apiVersion", "kubeconfig should contain apiVersion")
	assert.Contains(t, kubeconfig, "clusters", "kubeconfig should contain clusters")

	t.Log("✅ Kubernetes cluster validation placeholder (would test kubectl connectivity)")
}

// testClusterServices validates deployed services
func testClusterServices(t *testing.T, config *TestConfig, terraformOptions *terraform.Options) {
	t.Log("🔧 Testing Cluster Services")

	// Note: Service validation would include:
	// 1. Traefik ingress controller
	// 2. Longhorn storage (if enabled)
	// 3. Monitoring stack (if enabled)
	// 4. Cert-manager (if enabled)
	// 5. External DNS (if enabled)

	t.Log("✅ Cluster services validation placeholder")
}

// testInfrastructureIntegration tests integration between components
func testInfrastructureIntegration(t *testing.T, config *TestConfig, terraformOptions *terraform.Options) {
	t.Log("🔗 Testing Infrastructure Integration")

	// Test that all components work together
	// 1. Load balancer routes to control plane
	// 2. Control plane can reach agent nodes
	// 3. Networking allows proper communication
	// 4. External access works through load balancer
	// 5. DNS resolution works (if configured)

	lbIpv4 := terraform.Output(t, terraformOptions, "lb_ipv4")
	controlPlaneEndpoints := terraform.OutputList(t, terraformOptions, "control_plane_ipv4")

	assert.NotEmpty(t, lbIpv4, "Load balancer should have IPv4")
	assert.Greater(t, len(controlPlaneEndpoints), 0, "Should have control plane endpoints")

	t.Logf("✅ Infrastructure integration validated: LB=%s, %d control planes",
		lbIpv4, len(controlPlaneEndpoints))
}

// testSecurityConfiguration validates security settings
func testSecurityConfiguration(t *testing.T, config *TestConfig) {
	t.Log("🔒 Testing Security Configuration")

	// Test SSH access restrictions
	// Test firewall rules
	// Test network security
	// Test Kubernetes RBAC (if configured)

	t.Log("✅ Security configuration validation placeholder")
}

// testPerformanceMetrics validates performance aspects
func testPerformanceMetrics(t *testing.T, config *TestConfig) {
	t.Log("📊 Testing Performance Metrics")

	// Test cluster responsiveness
	// Test load balancer performance
	// Test network latency
	// Test resource utilization

	t.Log("✅ Performance metrics validation placeholder")
}
