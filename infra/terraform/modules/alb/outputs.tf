output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN of the default target group"
  value       = aws_lb_target_group.default.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : ""
}

output "alb_logs_bucket" {
  description = "S3 bucket for ALB logs"
  value       = var.create_log_bucket ? aws_s3_bucket.alb_logs[0].id : var.access_logs_bucket
}

output "alb_controller_role_arn" {
  description = "IAM role ARN for ALB Ingress Controller"
  value       = var.create_alb_controller_role ? aws_iam_role.alb_ingress_controller[0].arn : ""
}