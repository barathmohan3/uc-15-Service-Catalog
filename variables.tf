

variable "template_url" {
  description = "URL of the CloudFormation template"
  type        = string
  default = "https://demobucketforservicecatalog.s3.us-east-1.amazonaws.com/todaydemo/bucket-old.yaml"
}

variable "launch_role_arn" {
  description = "ARN of the IAM role for launching the product"
  type        = string
  default = "arn:aws:iam::676206899900:role/servicecatalogaccesss"
}

variable "user_arn" {
  description = "ARN of the IAM user for accessing the portfolio"
  type        = string
  default = "arn:aws:iam::676206899900:user/svc"

}
