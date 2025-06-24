

variable "template_url" {
  description = "URL of the CloudFormation template"
  type        = string
  default = "https://your-unique-sc-bucket-name.s3.us-east-1.amazonaws.com/helloworld.yaml"
}

variable "launch_role_arn" {
  description = "ARN of the IAM role for launching the product"
  type        = string
  default = "arn:aws:iam::650251701672:role/ServiceCatalogLaunchRole"
}

variable "user_arn" {
  description = "ARN of the IAM user for accessing the portfolio"
  type        = string
  default = "arn:aws:iam::650251701672:user/bmware_terraform"

}
