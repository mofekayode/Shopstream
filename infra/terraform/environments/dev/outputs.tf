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

output "region" {
  description = "AWS Region"
  value       = var.aws_region
}