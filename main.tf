provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_object" "helloworld_tar" {
  bucket = aws_s3_bucket.artifact_bucket.id
  key    = "helloworld.tar.gz"
  source = "${path.module}/helloworld.tar.gz"
  etag   = filemd5("${path.module}/helloworld.tar.gz")
}

resource "aws_iam_role" "launch_role" {
  name = "ServiceCatalogLaunchRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "servicecatalog.amazonaws.com"
      }
    }]
  })
}

resource "aws_servicecatalog_portfolio" "portfolio" {
  name          = var.portfolio_name
  description   = "Portfolio created by Terraform"
  provider_name = var.portfolio_owner
}

resource "aws_cloudformation_stack" "sc_stack" {
  name          = "SCProductSetupStack"
  template_body = file("${path.module}/templates/sc_setup.yaml")

  parameters = {
    PortfolioId = aws_servicecatalog_portfolio.s3_portfolio.id
    ArtifactUrl = "https://${aws_s3_bucket.artifact_bucket.bucket}.s3.amazonaws.com/${aws_s3_bucket_object.helloworld_tar.key}"
    RoleArn     = var.launch_role_arn
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]
}

resource "aws_servicecatalog_portfolio_share" "org_share" {
  portfolio_id = aws_servicecatalog_portfolio.s3_portfolio.id
  organization_node {
    type  = "ORGANIZATION"
    value = var.org_id
  }
}
