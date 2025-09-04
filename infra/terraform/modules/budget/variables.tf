variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD"
  type        = string
  default     = "100"
}

variable "notification_emails" {
  description = "Email addresses for budget notifications"
  type        = list(string)
  default     = []
}

variable "service_budgets" {
  description = "Map of service names to their monthly budget amounts"
  type        = map(string)
  default = {
    "Amazon Elastic Container Service for Kubernetes" = "50"
    "Amazon Relational Database Service"              = "30"
    "Amazon Simple Storage Service"                   = "10"
  }
}

variable "ec2_instance_hours_limit" {
  description = "Monthly limit for EC2 instance hours"
  type        = string
  default     = "1000"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}