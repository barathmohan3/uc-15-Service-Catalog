provider "aws" {
  region = var.region
}

# Upload the HelloWorld product artifact (zip or tar.gz)
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_object" "helloworld_artifact" {
  bucket = aws_s3_bucket.artifact_bucket.id
  key    = "helloworld.tar.gz"
  source = var.helloworld_source_path   # Path to downloaded tar from GitHub
  etag   = filemd5(var.helloworld_source_path)
}

# IAM Role for product launch
resource "aws_iam_role" "launch_role" {
  name = "ServiceCatalogLaunchRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "servicecatalog.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

# Portfolio creation
resource "aws_servicecatalog_portfolio" "portfolio" {
  name          = var.portfolio_name
  description   = "Demo Portfolio for HelloWorld App"
  provider_name = var.portfolio_owner
}

# Product creation
resource "aws_servicecatalog_product" "product" {
  name        = var.product_name
  owner       = var.portfolio_owner
  description = "HelloWorld Terraform Product"
  distributor = "Terraform Demo"
  type        = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    name                  = "v1"
    description           = "First version"
    type                  = "TEMPLATE"
    disable_template_validation = false
    template_url          = "https://${aws_s3_bucket.artifact_bucket.bucket}.s3.amazonaws.com/${aws_s3_bucket_object.helloworld_artifact.key}"
  }
}

# Associate product with portfolio
resource "aws_servicecatalog_portfolio_product_association" "association" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = aws_servicecatalog_product.product.id
}

# Add launch constraint to specify IAM role
resource "aws_servicecatalog_launch_constraint" "launch" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = aws_servicecatalog_product.product.id
  role_arn     = aws_iam_role.launch_role.arn
}

# Share portfolio with your AWS Organization
resource "aws_servicecatalog_portfolio_share" "org_share" {
  portfolio_id      = aws_servicecatalog_portfolio.portfolio.id
  share_tag_options = false
  organization_node {
    type  = "ORGANIZATION"
    value = var.organization_id
  }
}
