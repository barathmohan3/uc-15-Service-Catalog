variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Unique S3 bucket name to store artifacts"
}

variable "portfolio_name" {
  description = "Name of the Service Catalog portfolio"
  default     = "HelloWorldPortfolio"
}

variable "portfolio_owner" {
  description = "Owner of the portfolio"
  default     = "YourCompany"
}

variable "org_id" {
  type        = string
}
