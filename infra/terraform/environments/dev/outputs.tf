output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "Cognito Client ID"
  value       = module.cognito.client_id
}

output "cognito_domain" {
  description = "Cognito Domain"
  value       = module.cognito.domain
}

output "media_bucket" {
  description = "Media storage bucket name"
  value       = module.s3.media_bucket_name
}

output "static_bucket" {
  description = "Static assets bucket name"
  value       = module.s3.static_bucket_name
}

output "audit_bucket" {
  description = "Audit logs bucket name"
  value       = module.s3.audit_bucket_name
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain"
  value       = module.cloudfront.distribution_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "region" {
  description = "AWS Region"
  value       = var.aws_region
}