provider "aws" {
  region = "us-east-1"
}

provider "tfe" {
  hostname = "app.terraform.io"
  token    = var.tfe_token
}

resource "tfe_organization" "org" {
  name  = var.tfc_organization
  email = "admin@example.com"
}

resource "tfe_workspace" "workspace" {
  name         = "webapp-workspace"
  organization = tfe_organization.org.id
}

resource "aws_servicecatalog_product" "webapp_product" {
  name         = "HelloWorldApp"
  owner        = "DevOps Team"
  product_type = "TERRAFORM_CLOUD"

  provisioning_artifact_parameters {
    name         = "v1"
    type         = "TERRAFORM_CLOUD"
    template_url = "https://app.terraform.io/app/${var.tfc_organization}/webapp-workspace/runs"
  }
}

resource "aws_servicecatalog_portfolio" "webapp_portfolio" {
  name          = "WebAppPortfolio"
  description   = "Portfolio for HelloWorld Web App"
  provider_name = "DevOps Team"
}

resource "aws_servicecatalog_portfolio_product_association" "association" {
  portfolio_id = aws_servicecatalog_portfolio.webapp_portfolio.id
  product_id   = aws_servicecatalog_product.webapp_product.id
}

resource "aws_servicecatalog_portfolio_share" "org_share" {
  portfolio_id = aws_servicecatalog_portfolio.webapp_portfolio.id

  organization_node {
    type  = "ORGANIZATION"
    value = var.aws_organization_id
  }
}

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

resource "aws_servicecatalog_launch_constraint" "launch" {
  portfolio_id = aws_servicecatalog_portfolio.webapp_portfolio.id
  product_id   = aws_servicecatalog_product.webapp_product.id
  role_arn     = aws_iam_role.launch_role.arn
}
