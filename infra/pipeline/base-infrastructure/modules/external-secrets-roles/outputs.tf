output "genfix_access_key_id" {
  description = "Access Key ID for genfix client IAM user"
  value       = aws_iam_access_key.external_secrets_genfix.id
  sensitive   = true
}

output "genfix_secret_access_key" {
  description = "Secret Access Key for genfix client IAM user"
  value       = aws_iam_access_key.external_secrets_genfix.secret
  sensitive   = true
}

output "site_access_key_id" {
  description = "Access Key ID for site client IAM user"
  value       = aws_iam_access_key.external_secrets_site.id
  sensitive   = true
}

output "site_secret_access_key" {
  description = "Secret Access Key for site client IAM user"
  value       = aws_iam_access_key.external_secrets_site.secret
  sensitive   = true
}

output "genfix_policy_arn" {
  description = "ARN of the IAM policy for genfix client"
  value       = aws_iam_policy.external_secrets_genfix.arn
}

output "site_policy_arn" {
  description = "ARN of the IAM policy for site client"
  value       = aws_iam_policy.external_secrets_site.arn
}
