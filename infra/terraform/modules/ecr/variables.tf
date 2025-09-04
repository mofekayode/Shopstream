variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "service_names" {
  description = "List of service names to create ECR repositories for"
  type        = list(string)
  default = [
    "identity-service",
    "catalog-service",
    "orders-service",
    "payments-service",
    "search-service",
    "media-service",
    "feed-service",
    "realtime-service",
    "analytics-service",
    "compliance-service",
    "frontend-shell",
    "frontend-catalog",
    "frontend-checkout",
    "frontend-feed",
    "frontend-admin"
  ]
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "max_image_count" {
  description = "Maximum number of images to retain"
  type        = number
  default     = 30
}

variable "untagged_image_expiry_days" {
  description = "Number of days to retain untagged images"
  type        = number
  default     = 7
}

variable "enable_cross_account_access" {
  description = "Enable cross-account access to ECR repositories"
  type        = bool
  default     = false
}

variable "cross_account_principals" {
  description = "List of AWS account ARNs to grant cross-account access"
  type        = list(string)
  default     = []
}

variable "enable_pull_through_cache" {
  description = "Enable pull through cache for Docker Hub and ECR Public"
  type        = bool
  default     = true
}

variable "enable_enhanced_scanning" {
  description = "Enable enhanced vulnerability scanning"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}