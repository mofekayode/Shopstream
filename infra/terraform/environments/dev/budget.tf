module "budget" {
  source = "../../modules/budget"

  project_name          = local.project_name
  environment           = local.environment
  monthly_budget_amount = "50"  # $50/month for dev environment
  notification_emails   = []    # Add your email here

  service_budgets = {
    "Amazon Elastic Container Service for Kubernetes" = "20"
    "Amazon Relational Database Service"              = "10"
    "Amazon Simple Storage Service"                   = "5"
    "Amazon EC2 - Other"                              = "10"
  }

  ec2_instance_hours_limit = "500"  # Limit for dev

  tags = local.common_tags
}