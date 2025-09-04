variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Read capacity units for provisioned mode"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units for provisioned mode"
  type        = number
  default     = 5
}

variable "max_read_capacity" {
  description = "Maximum read capacity for auto-scaling"
  type        = number
  default     = 100
}

variable "max_write_capacity" {
  description = "Maximum write capacity for auto-scaling"
  type        = number
  default     = 100
}

variable "enable_autoscaling" {
  description = "Enable auto-scaling for provisioned capacity"
  type        = bool
  default     = true
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "enable_ttl" {
  description = "Enable TTL for automatic item expiration"
  type        = bool
  default     = false
}

variable "enable_streams" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "DynamoDB Streams view type"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}