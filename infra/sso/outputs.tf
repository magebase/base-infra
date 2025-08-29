output "sso_instance_arn" {
  description = "ARN of the AWS SSO instance"
  value       = aws_ssoadmin_instances.sso_instance.arns[0]
}

output "sso_instance_identity_store_id" {
  description = "Identity Store ID for the AWS SSO instance"
  value       = aws_ssoadmin_instances.sso_instance.identity_store_ids[0]
}

output "developer_permission_set_arn" {
  description = "ARN of the developer permission set"
  value       = aws_ssoadmin_permission_set.developer.arn
}

output "admin_permission_set_arn" {
  description = "ARN of the admin permission set"
  value       = aws_ssoadmin_permission_set.admin.arn
}

output "sso_start_url" {
  description = "AWS SSO start URL"
  value       = "https://${aws_ssoadmin_instances.sso_instance.arns[0]}/start"
}
