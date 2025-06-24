
output "portfolio_id" {
  description = "ID of the Service Catalog portfolio"
  value       = aws_servicecatalog_portfolio.s3_portfolio.id
}

output "product_id" {
  description = "ID of the Service Catalog product"
  value       = aws_servicecatalog_product.s3_product.id
}
