variable "external_secrets_trust_account_arn" {
  description = "ARN of the account that can assume the external secrets roles"
  type        = string
}

variable "client_name" {
  description = "Name of the client for which to create the IAM role and policy"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
