module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name            = local.project_name
  environment             = local.environment
  kms_key_id              = module.kms.cloudwatch_key_arn
  cpu_threshold           = 70  # Alert earlier in dev
  memory_threshold        = 70  # Alert earlier in dev
  response_time_threshold = 2   # More lenient in dev
  alert_emails            = []  # Add your email here
  enable_synthetics       = false  # Save costs in dev
  enable_container_insights = true
  enable_xray             = true
  xray_sampling_rate      = 0.05  # Lower sampling in dev

  log_groups = {
    "application" = { retention_days = 3 }
    "audit"       = { retention_days = 30 }
    "performance" = { retention_days = 7 }
  }

  tags = local.common_tags
}