# API Gateway configuration for dev environment
module "api_gateway" {
  source = "../../modules/api-gateway"

  project_name     = local.project_name
  environment      = local.environment
  alb_listener_arn = module.alb.listener_https_arn

  # Custom domain - uncomment when Route53 zone is ready
  # domain_name     = "api-dev.${local.domain_name}"
  # certificate_arn = module.acm.certificate_arn

  # Dev environment rate limiting (more permissive)
  throttle_burst_limit = 2000
  throttle_rate_limit  = 5000
  quota_limit          = 500000
  quota_period         = "DAY"

  # CORS for local development
  cors_allow_origins = [
    "http://localhost:3000",
    "http://localhost:3001",
    "http://localhost:3002",
    "http://localhost:3003",
    "https://${module.cloudfront.distribution_domain_name}"
  ]

  cors_allow_headers = [
    "content-type",
    "x-amz-date",
    "authorization",
    "x-api-key",
    "x-amz-security-token",
    "x-request-id",
    "x-correlation-id"
  ]

  # Logging configuration
  enable_access_logs = true
  log_retention_days = 3 # Shorter retention for dev
  enable_xray        = true

  tags = merge(
    local.common_tags,
    {
      Component = "api-gateway"
    }
  )
}

# Store API keys in Secrets Manager
resource "aws_secretsmanager_secret" "api_keys" {
  name_prefix = "${local.project_name}-${local.environment}-api-keys-"
  description = "API Gateway keys for ${local.environment} environment"

  tags = merge(
    local.common_tags,
    {
      Component = "api-gateway"
    }
  )
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  secret_id = aws_secretsmanager_secret.api_keys.id
  secret_string = jsonencode({
    web     = module.api_gateway.api_key_values["web"]
    mobile  = module.api_gateway.api_key_values["mobile"]
    partner = module.api_gateway.api_key_values["partner"]
  })
}

# CloudWatch Alarms for API Gateway
resource "aws_cloudwatch_metric_alarm" "api_4xx_errors" {
  alarm_name          = "${local.project_name}-${local.environment}-api-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "50" # Lower threshold for dev
  alarm_description   = "API Gateway 4xx errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = module.api_gateway.api_id
    Stage   = local.environment
  }

  tags = merge(
    local.common_tags,
    {
      Component = "api-gateway"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "api_5xx_errors" {
  alarm_name          = "${local.project_name}-${local.environment}-api-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10" # Alert quickly on server errors
  alarm_description   = "API Gateway 5xx errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = module.api_gateway.api_id
    Stage   = local.environment
  }

  tags = merge(
    local.common_tags,
    {
      Component = "api-gateway"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "api_latency" {
  alarm_name          = "${local.project_name}-${local.environment}-api-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000" # 1 second average latency
  alarm_description   = "API Gateway high latency"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = module.api_gateway.api_id
    Stage   = local.environment
  }

  tags = merge(
    local.common_tags,
    {
      Component = "api-gateway"
    }
  )
}

# Outputs for other services to use
output "api_gateway_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.stage_invoke_url
}

output "api_gateway_id" {
  description = "API Gateway ID"
  value       = module.api_gateway.api_id
}

output "api_keys_secret_arn" {
  description = "ARN of the secret containing API keys"
  value       = aws_secretsmanager_secret.api_keys.arn
}

output "api_keys_secret_name" {
  description = "Name of the secret containing API keys"
  value       = aws_secretsmanager_secret.api_keys.name
}