output "api_id" {
  description = "ID of the HTTP API Gateway"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "The URI of the API"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_arn" {
  description = "ARN of the API Gateway"
  value       = aws_apigatewayv2_api.main.arn
}

output "stage_id" {
  description = "ID of the API Gateway stage"
  value       = aws_apigatewayv2_stage.main.id
}

output "stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_apigatewayv2_stage.main.arn
}

output "stage_invoke_url" {
  description = "Invoke URL for the API Gateway stage"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "vpc_link_id" {
  description = "ID of the VPC Link"
  value       = var.vpc_link_id != "" ? var.vpc_link_id : aws_apigatewayv2_vpc_link.main[0].id
}

output "rest_api_id" {
  description = "ID of the REST API Gateway (for API key support)"
  value       = aws_api_gateway_rest_api.main.id
}

output "rest_api_arn" {
  description = "ARN of the REST API Gateway"
  value       = aws_api_gateway_rest_api.main.arn
}

output "api_keys" {
  description = "Map of API key names to IDs"
  value = {
    for k, v in aws_api_gateway_api_key.client_keys : k => v.id
  }
  sensitive = true
}

output "api_key_values" {
  description = "Map of API key names to values"
  value = {
    for k, v in aws_api_gateway_api_key.client_keys : k => v.value
  }
  sensitive = true
}

output "usage_plan_id" {
  description = "ID of the usage plan"
  value       = aws_api_gateway_usage_plan.main.id
}

output "custom_domain_name" {
  description = "Custom domain name for the API"
  value       = var.domain_name != "" ? aws_apigatewayv2_domain_name.main[0].domain_name : null
}

output "custom_domain_hosted_zone_id" {
  description = "Hosted zone ID for the custom domain"
  value       = var.domain_name != "" ? aws_apigatewayv2_domain_name.main[0].domain_name_configuration[0].hosted_zone_id : null
}

output "custom_domain_target_domain_name" {
  description = "Target domain name for the custom domain"
  value       = var.domain_name != "" ? aws_apigatewayv2_domain_name.main[0].domain_name_configuration[0].target_domain_name : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.enable_access_logs ? aws_cloudwatch_log_group.api[0].name : null
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = var.enable_access_logs ? aws_cloudwatch_log_group.api[0].arn : null
}