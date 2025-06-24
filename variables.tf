variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Unique S3 bucket name to store artifacts"
  type        = string
}

variable "portfolio_name" {
  description = "Name of the Service Catalog portfolio"
  default     = "HelloWorldPortfolio"
}

variable "portfolio_owner" {
  description = "Owner of the portfolio"
  default     = "YourCompany"
}

variable "organization_id" {
  description = "AWS Organization ID (e.g., o-xxxxxxx)"
  type        = string
}

variable "account_id" {
  description = "Target AWS account to share the portfolio with"
  type        = string
}

