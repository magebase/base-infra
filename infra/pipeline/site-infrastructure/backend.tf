# S3 backend in management account
terraform {
  backend "s3" {
    bucket         = "magebase-tf-state-management-ap-southeast-1"
    key            = "site-infrastructure/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "magebase-terraform-locks-management"
    role_arn       = "arn:aws:iam::${var.management_account_id}:role/${var.pipeline_role_name}"
  }
}
