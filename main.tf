terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.region
}

# S3 bucket and objects
resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_object" "helloworld_template" {
  bucket       = aws_s3_bucket.artifact_bucket.id
  key          = "helloworld.yaml"
  source       = "${path.module}/artifacts/helloworld.yaml"
  etag         = filemd5("${path.module}/artifacts/helloworld.yaml")
}

# IAM Launch Role
resource "aws_iam_role" "launch_role" {
  name = "ServiceCatalogLaunchRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "servicecatalog.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Portfolio
resource "aws_servicecatalog_portfolio" "portfolio" {
  name          = var.portfolio_name
  description   = "Portfolio created by Terraform"
  provider_name = var.portfolio_owner
}

# Create Product directly in Terraform
resource "aws_servicecatalog_product" "helloworld" {
  name              = "HelloWorldProduct"
  owner             = "BM"
  description       = "HelloWorld Service Catalog product"
  type              = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    name          = "v1"
    description   = "Initial version"
    type          = "CLOUD_FORMATION_TEMPLATE"
    template_url  = "https://${aws_s3_bucket.artifact_bucket.bucket}.s3.amazonaws.com/${aws_s3_object.helloworld_template.key}"
  }
}

# Associate Product with Portfolio
resource "aws_servicecatalog_product_portfolio_association" "assoc" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = aws_servicecatalog_product.helloworld.id
}

# Create Launch Constraint
resource "aws_servicecatalog_launch_constraint" "launch" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = aws_servicecatalog_product.helloworld.id
  role_arn     = aws_iam_role.launch_role.arn
}

# Share with AWS Account
resource "aws_servicecatalog_portfolio_share" "account_share" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  principal_id = var.account_id
  type         = "ACCOUNT"
}
