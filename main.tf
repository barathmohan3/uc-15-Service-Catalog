
resource "aws_servicecatalog_portfolio" "s3_portfolio" {
  name          = "S3 Portfolio"
  description   = "Portfolio for provisioning S3 buckets"
  provider_name = "YourCompany"
}

resource "aws_servicecatalog_product" "s3_product" {
  name          = "S3 Bucket Product"
  owner         = "YourCompany"
  type          = "CLOUD_FORMATION_TEMPLATE"
  provisioning_artifact_parameters {
    name           = "v1"
    type           = "CLOUD_FORMATION_TEMPLATE"
    template_url   = var.template_url
  }
}

resource "aws_servicecatalog_product_portfolio_association" "association" {
  portfolio_id = aws_servicecatalog_portfolio.s3_portfolio.id
  product_id   = aws_servicecatalog_product.s3_product.id
}



resource "aws_servicecatalog_constraint" "launch_constraint" {
  portfolio_id = aws_servicecatalog_portfolio.s3_portfolio.id
  product_id   = aws_servicecatalog_product.s3_product.id
  type         = "LAUNCH"
  parameters   = jsonencode({
    RoleArn = var.launch_role_arn
  })
}

resource "aws_servicecatalog_tag_option" "env_tag" {
  key   = "env"
  value = "dev"
}

resource "aws_servicecatalog_tag_option_resource_association" "tag_association" {
  resource_id = aws_servicecatalog_product.s3_product.id
  tag_option_id = aws_servicecatalog_tag_option.env_tag.id
}

resource "aws_servicecatalog_principal_portfolio_association" "user_access" {
  portfolio_id   = aws_servicecatalog_portfolio.s3_portfolio.id
  principal_arn  = var.user_arn
  principal_type = "IAM"
}
