variable "domain_name" {
  description = "The domain name to manage"
  type        = string
}

variable "create_zone" {
  description = "Whether to create a new hosted zone"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names for the certificate"
  type        = list(string)
  default     = []
}

variable "enable_ses" {
  description = "Enable SES domain verification and DKIM"
  type        = bool
  default     = true
}

variable "enable_ses_receiving" {
  description = "Enable SES email receiving"
  type        = bool
  default     = false
}

variable "dmarc_policy" {
  description = "DMARC policy (none, quarantine, or reject)"
  type        = string
  default     = "quarantine"
}

variable "dmarc_email" {
  description = "Email address for DMARC reports"
  type        = string
  default     = "postmaster@example.com"
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for alias record"
  type        = string
  default     = ""
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
  default     = ""
}

variable "cloudfront_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID"
  type        = string
  default     = "Z2FDTNDATAQYW2" # This is always the same for CloudFront
}

variable "create_www_record" {
  description = "Create www subdomain record"
  type        = bool
  default     = true
}

variable "enable_health_check" {
  description = "Enable Route53 health check"
  type        = bool
  default     = false
}

variable "health_check_domain" {
  description = "Domain for health check"
  type        = string
  default     = ""
}

variable "health_check_port" {
  description = "Port for health check"
  type        = number
  default     = 443
}

variable "health_check_protocol" {
  description = "Protocol for health check"
  type        = string
  default     = "HTTPS"
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/health"
}

variable "health_check_failure_threshold" {
  description = "Number of consecutive health check failures required to consider unhealthy"
  type        = number
  default     = 3
}

variable "health_check_interval" {
  description = "Interval between health checks"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}