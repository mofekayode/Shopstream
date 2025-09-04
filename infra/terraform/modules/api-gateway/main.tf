# API Gateway HTTP API (v2) for REST endpoints
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway for ${var.project_name}"

  cors_configuration {
    allow_credentials = false
    allow_headers     = var.cors_allow_headers
    allow_methods     = var.cors_allow_methods
    allow_origins     = var.cors_allow_origins
    expose_headers    = ["*"]
    max_age           = 300
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-api"
      Environment = var.environment
    }
  )
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api" {
  count = var.enable_access_logs ? 1 : 0

  name              = "/aws/api-gateway/${aws_apigatewayv2_api.main.name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-api-logs"
      Environment = var.environment
    }
  )
}

# API Gateway Stage with throttling and logging
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.environment
  auto_deploy = true

  # Access logging
  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api[0].arn
      format = jsonencode({
        requestId               = "$context.requestId"
        sourceIp                = "$context.identity.sourceIp"
        requestTime             = "$context.requestTime"
        protocol                = "$context.protocol"
        httpMethod              = "$context.httpMethod"
        resourcePath            = "$context.resourcePath"
        routeKey                = "$context.routeKey"
        status                  = "$context.status"
        responseLength          = "$context.responseLength"
        error                   = "$context.error.message"
        integrationError        = "$context.integrationError"
        integrationLatency      = "$context.integrationLatency"
        integrationRequestId    = "$context.integration.requestId"
        integrationStatus       = "$context.integration.status"
        responseLatency         = "$context.responseLatency"
        xrayTraceId             = "$context.xrayTraceId"
      })
    }
  }

  # Default route settings with throttling
  default_route_settings {
    detailed_metrics_enabled = true
    throttle_burst_limit     = var.throttle_burst_limit
    throttle_rate_limit      = var.throttle_rate_limit
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-stage"
      Environment = var.environment
    }
  )
}

# VPC Link for private integration with ALB
resource "aws_apigatewayv2_vpc_link" "main" {
  count = var.vpc_link_id == "" ? 1 : 0

  name               = "${var.project_name}-${var.environment}-vpc-link"
  security_group_ids = [aws_security_group.vpc_link[0].id]
  subnet_ids         = data.aws_subnets.private.ids

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-vpc-link"
      Environment = var.environment
    }
  )
}

# Security group for VPC Link
resource "aws_security_group" "vpc_link" {
  count = var.vpc_link_id == "" ? 1 : 0

  name_prefix = "${var.project_name}-${var.environment}-vpc-link-"
  description = "Security group for API Gateway VPC Link"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-vpc-link-sg"
      Environment = var.environment
    }
  )
}

# Integration with ALB
resource "aws_apigatewayv2_integration" "alb" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = var.alb_listener_arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = var.vpc_link_id != "" ? var.vpc_link_id : aws_apigatewayv2_vpc_link.main[0].id

  payload_format_version = "2.0"
  timeout_milliseconds   = 30000

  request_parameters = {
    "overwrite:header.x-forwarded-for" = "$context.identity.sourceIp"
    "overwrite:header.x-api-key"       = "$context.identity.apiKey"
  }
}

# Routes for different services
locals {
  service_routes = {
    "auth"     = "/api/auth/{proxy+}"
    "users"    = "/api/users/{proxy+}"
    "catalog"  = "/api/catalog/{proxy+}"
    "orders"   = "/api/orders/{proxy+}"
    "payments" = "/api/payments/{proxy+}"
    "search"   = "/api/search/{proxy+}"
    "media"    = "/api/media/{proxy+}"
    "feed"     = "/api/feed/{proxy+}"
  }
}

# Create routes for each service
resource "aws_apigatewayv2_route" "services" {
  for_each = local.service_routes

  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY ${each.value}"
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"

  # Route-specific rate limiting can be added here
  request_parameter {
    location        = "header"
    name            = "x-api-key"
    required        = false
  }
}

# Health check route
resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

# Custom domain (optional)
resource "aws_apigatewayv2_domain_name" "main" {
  count = var.domain_name != "" ? 1 : 0

  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = merge(
    var.tags,
    {
      Name        = var.domain_name
      Environment = var.environment
    }
  )
}

# API mapping for custom domain
resource "aws_apigatewayv2_api_mapping" "main" {
  count = var.domain_name != "" ? 1 : 0

  api_id      = aws_apigatewayv2_api.main.id
  domain_name = aws_apigatewayv2_domain_name.main[0].id
  stage       = aws_apigatewayv2_stage.main.id
}

# API Gateway REST API for services that need API Keys
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-${var.environment}-rest-api"
  description = "REST API Gateway with API Key support for ${var.project_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-rest-api"
      Environment = var.environment
    }
  )
}

# Request Validator
resource "aws_api_gateway_request_validator" "main" {
  name                        = "request-validator"
  rest_api_id                 = aws_api_gateway_rest_api.main.id
  validate_request_body       = true
  validate_request_parameters = true
}

# API Key for client authentication
resource "aws_api_gateway_api_key" "client_keys" {
  for_each = toset(["web", "mobile", "partner"])

  name        = "${var.project_name}-${var.environment}-${each.key}-key"
  description = "API key for ${each.key} client"

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-${each.key}-key"
      Environment = var.environment
      Client      = each.key
    }
  )
}

# Usage Plan with quotas and throttling
resource "aws_api_gateway_usage_plan" "main" {
  name        = "${var.project_name}-${var.environment}-usage-plan"
  description = "Usage plan with rate limiting and quotas"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_deployment.main.stage_name
  }

  quota_settings {
    limit  = var.quota_limit
    period = var.quota_period
  }

  throttle_settings {
    burst_limit = var.throttle_burst_limit
    rate_limit  = var.throttle_rate_limit
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-usage-plan"
      Environment = var.environment
    }
  )
}

# Usage Plan Key associations
resource "aws_api_gateway_usage_plan_key" "main" {
  for_each = aws_api_gateway_api_key.client_keys

  key_id        = each.value.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

# Deployment
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.environment

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_rest_api.main,
    aws_api_gateway_request_validator.main
  ]
}

# Method settings for detailed metrics and logging
resource "aws_api_gateway_method_settings" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_deployment.main.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    data_trace_enabled     = var.environment != "production"
    throttling_burst_limit = var.throttle_burst_limit
    throttling_rate_limit  = var.throttle_rate_limit
  }
}

# WAF Web ACL Association (if WAF exists)
data "aws_wafv2_web_acl" "main" {
  count = var.environment == "production" ? 1 : 0

  name  = "${var.project_name}-${var.environment}-waf"
  scope = "REGIONAL"
}

resource "aws_wafv2_web_acl_association" "api_gateway" {
  count = var.environment == "production" ? 1 : 0

  resource_arn = aws_apigatewayv2_stage.main.arn
  web_acl_arn  = data.aws_wafv2_web_acl.main[0].arn
}

# Data sources
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}