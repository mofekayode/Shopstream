resource "aws_cloudwatch_log_group" "application" {
  for_each = var.log_groups

  name              = "/aws/${var.project_name}/${var.environment}/${each.key}"
  retention_in_days = each.value.retention_days
  kms_key_id        = var.kms_key_id

  tags = merge(
    var.tags,
    {
      Name        = "/aws/${var.project_name}/${var.environment}/${each.key}"
      Environment = var.environment
      Service     = each.key
    }
  )
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-main"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EKS", "cluster_node_count", { stat = "Average", label = "Node Count" }],
            [".", "cluster_failed_node_count", { stat = "Sum", label = "Failed Nodes" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "EKS Cluster Health"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }],
            [".", "HTTPCode_Target_4XX_Count", { stat = "Sum" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ALB Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum" }],
            [".", "Errors", { stat = "Sum" }],
            [".", "Duration", { stat = "Average" }],
            [".", "ConcurrentExecutions", { stat = "Maximum" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Lambda Functions"
        }
      },
      {
        type = "log"
        properties = {
          query   = "SOURCE '/aws/${var.project_name}/${var.environment}/*' | fields @timestamp, @message | sort @timestamp desc | limit 100"
          region  = data.aws_region.current.name
          title   = "Recent Application Logs"
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "This metric monitors EKS node CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = "${var.project_name}-${var.environment}"
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.project_name}-${var.environment}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "This metric monitors EKS node memory utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = "${var.project_name}-${var.environment}"
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Alert when we have unhealthy ALB targets"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = var.response_time_threshold
  alarm_description   = "Alert when ALB response time is too high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-alerts"
      Environment = var.environment
    }
  )
}

resource "aws_sns_topic_subscription" "alerts_email" {
  for_each = toset(var.alert_emails)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

# CloudWatch Logs Insights Queries
resource "aws_cloudwatch_query_definition" "error_logs" {
  name = "${var.project_name}-${var.environment}-error-logs"

  log_group_names = [
    "/aws/${var.project_name}/${var.environment}/*"
  ]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100
EOF
}

resource "aws_cloudwatch_query_definition" "slow_requests" {
  name = "${var.project_name}-${var.environment}-slow-requests"

  log_group_names = [
    "/aws/${var.project_name}/${var.environment}/*"
  ]

  query_string = <<EOF
fields @timestamp, @message, duration
| filter duration > ${var.slow_request_threshold}
| stats count() by bin(5m)
EOF
}

# Container Insights for EKS
resource "aws_iam_role" "cloudwatch_agent" {
  count = var.enable_container_insights ? 1 : 0

  name = "${var.project_name}-${var.environment}-cloudwatch-agent"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  count = var.enable_container_insights ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_agent[0].name
}

# X-Ray Service Map
resource "aws_xray_sampling_rule" "main" {
  count = var.enable_xray ? 1 : 0

  rule_name      = "${var.project_name}-${var.environment}"
  priority       = 9000
  version        = 1
  reservoir_size = 1
  fixed_rate     = var.xray_sampling_rate
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"

  attributes = {
    Environment = var.environment
  }
}

# CloudWatch Synthetics Canary
resource "aws_synthetics_canary" "health_check" {
  count = var.enable_synthetics ? 1 : 0

  name                 = "${var.project_name}-${var.environment}-health"
  artifact_s3_location = "s3://${aws_s3_bucket.synthetics[0].bucket}/"
  execution_role_arn   = aws_iam_role.synthetics[0].arn
  handler              = "apiCanary.handler"
  zip_file             = data.archive_file.synthetics[0].output_path
  runtime_version      = "syn-nodejs-puppeteer-3.9"
  start_canary         = true

  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    timeout_in_seconds = 60
    memory_in_mb       = 960
  }

  success_retention_period = 31
  failure_retention_period = 31

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-health"
      Environment = var.environment
    }
  )
}

resource "aws_s3_bucket" "synthetics" {
  count = var.enable_synthetics ? 1 : 0

  bucket = "${var.project_name}-${var.environment}-synthetics"

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "synthetics" {
  count = var.enable_synthetics ? 1 : 0

  bucket = aws_s3_bucket.synthetics[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "synthetics" {
  count = var.enable_synthetics ? 1 : 0

  name = "${var.project_name}-${var.environment}-synthetics"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "synthetics" {
  count = var.enable_synthetics ? 1 : 0

  name = "synthetics-policy"
  role = aws_iam_role.synthetics[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.synthetics[0].arn,
          "${aws_s3_bucket.synthetics[0].arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "synthetics" {
  count = var.enable_synthetics ? 1 : 0

  type        = "zip"
  output_path = "/tmp/synthetics.zip"

  source {
    content  = file("${path.module}/canary.js")
    filename = "nodejs/node_modules/apiCanary.js"
  }
}

data "aws_region" "current" {}