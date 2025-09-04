# API Gateway Module

This module creates an AWS API Gateway setup with both HTTP API (v2) and REST API for the Shopstream platform.

## Features

- **HTTP API (v2)**: Primary API for most services (cheaper, faster, better for ALB integration)
- **REST API**: For services requiring API keys and usage plans
- **Rate Limiting**: Built-in throttling at multiple levels
- **API Keys**: Support for different client types (web, mobile, partner)
- **Usage Plans**: Quotas and throttling per API key
- **VPC Link**: Private integration with ALB
- **CORS**: Configurable CORS settings
- **Logging**: CloudWatch access logs and X-Ray tracing
- **WAF Integration**: Automatic WAF association for production

## Rate Limiting Hierarchy

1. **Stage Level**: Default throttling for all routes
2. **Route Level**: Can override for specific endpoints
3. **Usage Plan**: Per API key quotas and throttling
4. **WAF**: Additional rate limiting rules (if enabled)

## Usage

```hcl
module "api_gateway" {
  source = "../../modules/api-gateway"

  project_name     = "shopstream"
  environment      = "dev"
  alb_listener_arn = module.alb.listener_arn

  # Custom domain (optional)
  domain_name     = "api.shopstream.com"
  certificate_arn = module.acm.certificate_arn

  # Rate limiting
  throttle_burst_limit = 5000
  throttle_rate_limit  = 10000
  quota_limit          = 1000000
  quota_period         = "DAY"

  # CORS
  cors_allow_origins = ["https://shopstream.com", "http://localhost:3000"]

  # Logging
  enable_access_logs = true
  log_retention_days = 7
  enable_xray        = true

  tags = local.common_tags
}
```

## Service Integration

Services should be configured to:

1. **Accept API Gateway headers**:
   - `x-forwarded-for`: Original client IP
   - `x-api-key`: API key (if using REST API)
   - `x-amz-trace-id`: X-Ray trace ID

2. **Handle rate limit responses**:
   - `429 Too Many Requests`: Client should implement exponential backoff
   - Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

3. **Path routing**:
   - `/api/auth/*` → identity-service
   - `/api/catalog/*` → catalog-service
   - `/api/orders/*` → orders-service
   - etc.

## API Keys

API keys are automatically created for:
- `web`: Web application clients
- `mobile`: Mobile application clients
- `partner`: Partner API integrations

Access keys from outputs:
```hcl
output "web_api_key" {
  value     = module.api_gateway.api_key_values["web"]
  sensitive = true
}
```

## Monitoring

### CloudWatch Metrics
- `4XXError`: Client errors
- `5XXError`: Server errors
- `Count`: Total requests
- `IntegrationLatency`: Backend processing time
- `Latency`: Total request time

### Alarms to Set
```hcl
resource "aws_cloudwatch_metric_alarm" "api_4xx_errors" {
  alarm_name          = "${var.project_name}-api-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors 4xx errors"
}
```

## Cost Optimization

- HTTP API is ~70% cheaper than REST API
- Use REST API only when API keys are required
- Enable caching for frequently accessed data
- Set appropriate throttling limits to prevent abuse

## Security Best Practices

1. Always use API keys for external clients
2. Enable WAF for production environments
3. Use VPC Link for private ALB integration
4. Implement request validation
5. Enable access logging for audit trails
6. Use least-privilege IAM roles

## Troubleshooting

### Common Issues

1. **429 Too Many Requests**
   - Check throttling limits
   - Review usage plan quotas
   - Consider increasing limits for legitimate traffic

2. **403 Forbidden**
   - Verify API key is included in header
   - Check API key is associated with usage plan
   - Ensure CORS is properly configured

3. **504 Gateway Timeout**
   - Backend service taking > 30 seconds
   - Check ALB target health
   - Review service logs

4. **Connection refused through VPC Link**
   - Verify security group rules
   - Check VPC Link is in correct subnets
   - Ensure ALB listener is configured