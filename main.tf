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

# S3 Bucket to store the tar.gz artifact
resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

# Upload the helloworld.tar.gz to S3
resource "aws_s3_object" "helloworld_tar" {
  bucket = aws_s3_bucket.artifact_bucket.id
  key    = "helloworld.tar.gz"
  source = "${path.module}/helloworld.tar.gz"
  etag   = filemd5("${path.module}/helloworld.tar.gz")
}

# IAM Role used as a launch constraint
resource "aws_iam_role" "launch_role" {
  name = "ServiceCatalogLaunchRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "servicecatalog.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Portfolio
resource "aws_servicecatalog_portfolio" "portfolio" {
  name          = var.portfolio_name
  description   = "Portfolio created by Terraform"
  provider_name = var.portfolio_owner
}

# CloudFormation Stack to create the SC Product + associate + launch constraint
resource "aws_cloudformation_stack" "sc_stack" {
  name          = "SCProductSetupStack"
  template_body = file("${path.module}/templates/sc_setup.yaml")

  parameters = {
    PortfolioId = aws_servicecatalog_portfolio.portfolio.id
    ArtifactUrl = "https://${aws_s3_bucket.artifact_bucket.bucket}.s3.amazonaws.com/${aws_s3_object.helloworld_tar.key}"
    RoleArn     = aws_iam_role.launch_role.arn
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]
}

# Share the Portfolio across the Organization
resource "aws_servicecatalog_portfolio_share" "org_share" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  principal_id = var.account_id
  type         = "ORGANIZATION"
}
