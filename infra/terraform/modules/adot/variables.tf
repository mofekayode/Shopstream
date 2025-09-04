variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  type        = string
}

variable "adot_namespace" {
  description = "Kubernetes namespace for ADOT"
  type        = string
  default     = "amazon-cloudwatch"
}

variable "collector_image" {
  description = "ADOT collector image"
  type        = string
  default     = "public.ecr.aws/aws-observability/aws-otel-collector:v0.35.0"
}

variable "collector_replicas" {
  description = "Number of collector replicas"
  type        = number
  default     = 2
}

variable "collector_cpu_limit" {
  description = "CPU limit for collector"
  type        = string
  default     = "1"
}

variable "collector_memory_limit" {
  description = "Memory limit for collector"
  type        = string
  default     = "2Gi"
}

variable "collector_cpu_request" {
  description = "CPU request for collector"
  type        = string
  default     = "200m"
}

variable "collector_memory_request" {
  description = "Memory request for collector"
  type        = string
  default     = "512Mi"
}

variable "enable_node_collector" {
  description = "Enable DaemonSet for node-level metrics"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "kms_key_id" {
  description = "KMS key ID for log encryption"
  type        = string
  default     = ""
}

variable "enable_prometheus" {
  description = "Enable Prometheus remote write"
  type        = bool
  default     = false
}

variable "prometheus_endpoint" {
  description = "Prometheus remote write endpoint"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}