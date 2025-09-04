variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "domain" {
  description = "Domain name for ArgoCD"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}

variable "service_type" {
  description = "Kubernetes service type for ArgoCD server"
  type        = string
  default     = "NodePort"
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_webhook_secret" {
  description = "GitHub webhook secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "target_revision" {
  description = "Target revision for root application"
  type        = string
  default     = "HEAD"
}

variable "apps_path" {
  description = "Path to applications in the repository"
  type        = string
  default     = "deployments/apps"
}

variable "enable_dex" {
  description = "Enable Dex for SSO"
  type        = bool
  default     = false
}

variable "enable_notifications" {
  description = "Enable notifications"
  type        = bool
  default     = false
}

variable "slack_token" {
  description = "Slack token for notifications"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_rollouts" {
  description = "Enable Argo Rollouts"
  type        = bool
  default     = false
}

variable "redis_ha" {
  description = "Enable Redis HA"
  type        = bool
  default     = false
}

variable "controller_replicas" {
  description = "Number of ArgoCD controller replicas"
  type        = number
  default     = 1
}

variable "server_replicas" {
  description = "Number of ArgoCD server replicas"
  type        = number
  default     = 1
}

variable "repo_server_replicas" {
  description = "Number of ArgoCD repo server replicas"
  type        = number
  default     = 1
}

variable "enable_aws_integration" {
  description = "Enable AWS integration (ECR, Secrets Manager)"
  type        = bool
  default     = true
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  type        = string
  default     = ""
}

variable "create_ingress" {
  description = "Create ingress for ArgoCD"
  type        = bool
  default     = true
}

variable "admin_groups" {
  description = "Groups with admin access"
  type        = list(string)
  default     = []
}

variable "readonly_groups" {
  description = "Groups with readonly access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}