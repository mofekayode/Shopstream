module "security" {
  source = "../../modules/security"

  project_name                  = local.project_name
  environment                   = local.environment
  cloudtrail_log_retention_days = 30  # Shorter retention for dev
  guardduty_notification_email  = ""  # Add your email here
  force_destroy                 = true # Allow destroying non-empty buckets in dev

  tags = local.common_tags
}