variable "client_name" {
  description = "Name of the client for which to create the IAM user and policy"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
