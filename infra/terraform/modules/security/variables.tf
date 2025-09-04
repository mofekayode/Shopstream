variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cloudtrail_log_retention_days" {
  description = "Number of days to retain CloudTrail logs"
  type        = number
  default     = 90
}

variable "guardduty_finding_publishing_frequency" {
  description = "Frequency of GuardDuty findings publishing"
  type        = string
  default     = "FIFTEEN_MINUTES"
}

variable "guardduty_notification_email" {
  description = "Email address for GuardDuty notifications"
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Force destroy S3 buckets even if not empty"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}