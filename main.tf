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

# Create S3 bucket to store CloudFormation template
resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

# Upload the CloudFormation template to S3
resource "aws_s3_object" "helloworld_template" {
  bucket = aws_s3_bucket.artifact_bucket.id
  key    = "helloworld.yaml"
  source = "${path.module}/artifacts/helloworld.yaml"
  etag   = filemd5("${path.module}/artifacts/helloworld.yaml")
}

resource "aws_s3_object" "index_file" {
  bucket = aws_s3_bucket.artifact_bucket.id
  key    = "index.html"
  source = "${path.module}/artifacts/index.html"
  content_type = "text/html"
  etag   = filemd5("${path.module}/artifacts/index.html")
}

# IAM Role used by Service Catalog to launch the product
resource "aws_iam_role" "launch_role" {
  name = "ServiceCatalogLaunchRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "servicecatalog.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Create the Portfolio
resource "aws_servicecatalog_portfolio" "portfolio" {
  name          = var.portfolio_name
  description   = "Portfolio created by Terraform"
  provider_name = var.portfolio_owner
}

# Create a CloudFormation stack to provision the SC Product and LaunchConstraint
resource "aws_cloudformation_stack" "sc_stack" {
  name          = "SCProductSetupStack"
  template_body = file("${path.module}/templates/sc_setup.yaml")

  parameters = {
    PortfolioId = aws_servicecatalog_portfolio.portfolio.id
    ArtifactUrl = "https://${aws_s3_bucket.artifact_bucket.bucket}.s3.amazonaws.com/${aws_s3_object.helloworld_template.key}"
    RoleArn     = aws_iam_role.launch_role.arn
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]
}

# Wait for the stack to finish, then use data lookup to get ProductId
data "aws_servicecatalog_product" "helloworld" {
  name = "HelloWorldProduct"
}

resource "aws_servicecatalog_portfolio_product_association" "assoc" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = data.aws_servicecatalog_product.helloworld.id
}

resource "aws_servicecatalog_launch_constraint" "launch" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = data.aws_servicecatalog_product.helloworld.id
  role_arn     = aws_iam_role.launch_role.arn
}

# Share the Portfolio with the organization
resource "aws_servicecatalog_portfolio_share" "org_share" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  principal_id = 211125784755  # Must be o-xxxxxxxx
  type         = "ACCOUNT"
}
