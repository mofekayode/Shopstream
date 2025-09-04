variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "secrets" {
  description = "Map of secrets to create"
  type = map(object({
    description     = string
    service         = string
    initial_value   = map(string)
    enable_rotation = bool
    rotation_days   = number
  }))
  default = {}
}

variable "recovery_window_days" {
  description = "Number of days to retain deleted secrets"
  type        = number
  default     = 7
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = ""
}

variable "replica_region" {
  description = "Region for secret replica"
  type        = string
  default     = ""
}

variable "replica_kms_key_id" {
  description = "KMS key ID for replica encryption"
  type        = string
  default     = ""
}

variable "create_db_secret" {
  description = "Create database credentials secret"
  type        = bool
  default     = true
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "subnet_ids" {
  description = "Subnet IDs for Lambda rotation function"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs for Lambda rotation function"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}