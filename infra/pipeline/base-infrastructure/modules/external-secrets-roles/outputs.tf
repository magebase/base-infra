output "genfix_role_arn" {
  description = "ARN of the IAM role for genfix client"
  value       = aws_iam_role.external_secrets_genfix.arn
}

output "site_role_arn" {
  description = "ARN of the IAM role for site client"
  value       = aws_iam_role.external_secrets_site.arn
}

output "genfix_policy_arn" {
  description = "ARN of the IAM policy for genfix client"
  value       = aws_iam_policy.external_secrets_genfix.arn
}

output "site_policy_arn" {
  description = "ARN of the IAM policy for site client"
  value       = aws_iam_policy.external_secrets_site.arn
}

output "client_role_arn" {
  description = "ARN of the IAM role for the specified client (when using template)"
  value       = var.client_name != "" ? aws_iam_role.external_secrets_client_template[0].arn : null
}

output "client_policy_arn" {
  description = "ARN of the IAM policy for the specified client (when using template)"
  value       = var.client_name != "" ? aws_iam_policy.external_secrets_client_template[0].arn : null
}
