output "collector_role_arn" {
  description = "IAM role ARN for ADOT collector"
  value       = aws_iam_role.adot_collector.arn
}

output "collector_service_account" {
  description = "Kubernetes service account for ADOT collector"
  value       = kubernetes_service_account.adot_collector.metadata[0].name
}

output "collector_namespace" {
  description = "Kubernetes namespace for ADOT"
  value       = kubernetes_namespace.adot.metadata[0].name
}

output "collector_service_endpoint" {
  description = "ADOT collector service endpoints"
  value = {
    otlp_grpc = "${kubernetes_service.adot_collector.metadata[0].name}.${kubernetes_namespace.adot.metadata[0].name}.svc.cluster.local:4317"
    otlp_http = "${kubernetes_service.adot_collector.metadata[0].name}.${kubernetes_namespace.adot.metadata[0].name}.svc.cluster.local:4318"
    xray      = "${kubernetes_service.adot_collector.metadata[0].name}.${kubernetes_namespace.adot.metadata[0].name}.svc.cluster.local:2000"
  }
}

output "log_group_name" {
  description = "CloudWatch log group for ADOT"
  value       = aws_cloudwatch_log_group.adot.name
}