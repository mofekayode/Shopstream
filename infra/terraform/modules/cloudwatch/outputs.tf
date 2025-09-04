output "log_group_names" {
  description = "Map of log group names"
  value = {
    for k, v in aws_cloudwatch_log_group.application : k => v.name
  }
}

output "log_group_arns" {
  description = "Map of log group ARNs"
  value = {
    for k, v in aws_cloudwatch_log_group.application : k => v.arn
  }
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "alarm_arns" {
  description = "Map of alarm ARNs"
  value = {
    high_cpu                = aws_cloudwatch_metric_alarm.high_cpu.arn
    high_memory             = aws_cloudwatch_metric_alarm.high_memory.arn
    alb_unhealthy_targets   = aws_cloudwatch_metric_alarm.alb_unhealthy_targets.arn
    alb_target_response_time = aws_cloudwatch_metric_alarm.alb_target_response_time.arn
  }
}

output "synthetics_canary_name" {
  description = "Name of the Synthetics canary"
  value       = var.enable_synthetics ? aws_synthetics_canary.health_check[0].name : ""
}

output "xray_sampling_rule_name" {
  description = "Name of the X-Ray sampling rule"
  value       = var.enable_xray ? aws_xray_sampling_rule.main[0].rule_name : ""
}