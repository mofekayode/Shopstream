variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener to integrate with"
  type        = string
}

variable "vpc_link_id" {
  description = "ID of the VPC Link for private integration"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Custom domain name for the API"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = ""
}

variable "enable_cors" {
  description = "Enable CORS configuration"
  type        = bool
  default     = true
}

variable "cors_allow_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_headers" {
  description = "Allowed headers for CORS"
  type        = list(string)
  default     = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token"]
}

variable "cors_allow_methods" {
  description = "Allowed methods for CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "throttle_burst_limit" {
  description = "API throttling burst limit"
  type        = number
  default     = 5000
}

variable "throttle_rate_limit" {
  description = "API throttling rate limit (requests per second)"
  type        = number
  default     = 10000
}

variable "quota_limit" {
  description = "Usage plan quota limit (requests per day)"
  type        = number
  default     = 1000000
}

variable "quota_period" {
  description = "Usage plan quota period"
  type        = string
  default     = "DAY"
}

variable "enable_access_logs" {
  description = "Enable access logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_xray" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}