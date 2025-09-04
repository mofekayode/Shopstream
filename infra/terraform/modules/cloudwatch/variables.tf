variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "log_groups" {
  description = "Map of log groups to create"
  type = map(object({
    retention_days = number
  }))
  default = {
    "application" = { retention_days = 7 }
    "audit"       = { retention_days = 90 }
    "performance" = { retention_days = 30 }
  }
}

variable "kms_key_id" {
  description = "KMS key ID for log encryption"
  type        = string
  default     = ""
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for alarm"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Memory utilization threshold for alarm"
  type        = number
  default     = 80
}

variable "response_time_threshold" {
  description = "ALB response time threshold in seconds"
  type        = number
  default     = 1
}

variable "slow_request_threshold" {
  description = "Threshold for slow requests in milliseconds"
  type        = number
  default     = 1000
}

variable "alert_emails" {
  description = "Email addresses for CloudWatch alerts"
  type        = list(string)
  default     = []
}

variable "enable_container_insights" {
  description = "Enable Container Insights for EKS"
  type        = bool
  default     = true
}

variable "enable_xray" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

variable "xray_sampling_rate" {
  description = "X-Ray sampling rate (0.0 to 1.0)"
  type        = number
  default     = 0.1
}

variable "enable_synthetics" {
  description = "Enable CloudWatch Synthetics canaries"
  type        = bool
  default     = false
}

variable "synthetics_endpoint_url" {
  description = "Endpoint URL for Synthetics health check"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}