output "argocd_namespace" {
  description = "ArgoCD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_url" {
  description = "ArgoCD server URL"
  value       = var.create_ingress ? "https://argocd.${var.domain}" : ""
}

output "argocd_server_role_arn" {
  description = "IAM role ARN for ArgoCD server"
  value       = var.enable_aws_integration ? aws_iam_role.argocd_server[0].arn : ""
}

output "argocd_initial_admin_secret" {
  description = "Name of the secret containing initial admin password"
  value       = "argocd-initial-admin-secret"
}

output "helm_release_name" {
  description = "Name of the ArgoCD Helm release"
  value       = helm_release.argocd.name
}

output "helm_release_status" {
  description = "Status of the ArgoCD Helm release"
  value       = helm_release.argocd.status
}