variable "region" {
  default = "us-east-1"
}

variable "bucket_name" {
  default = "sc-artifact-demo-helloworld" # Must be globally unique
}

variable "helloworld_source_path" {
  description = "Path to the HelloWorld tar.gz downloaded from GitHub"
  type        = string
}

variable "portfolio_name" {
  default = "HelloWorldPortfolio"
}

variable "portfolio_owner" {
  default = "BM"
}

variable "product_name" {
  default = "HelloWorldProduct"
}

variable "organization_id" {
  description = "Your AWS Organization ID (e.g., o-xxxxxxxxxx)"
  type        = string
}
