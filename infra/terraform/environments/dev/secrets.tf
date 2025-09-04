module "secrets" {
  source = "../../modules/secrets"

  project_name         = local.project_name
  environment          = local.environment
  recovery_window_days = 0  # Immediate deletion in dev
  kms_key_id          = module.kms.secrets_key_arn
  
  secrets = {
    "stripe-api-key" = {
      description     = "Stripe API key"
      service         = "payments-service"
      initial_value   = { key = "sk_test_placeholder" }
      enable_rotation = false
      rotation_days   = 0
    }
    "jwt-secret" = {
      description     = "JWT signing secret"
      service         = "identity-service"
      initial_value   = { secret = "dev-jwt-secret-change-in-production" }
      enable_rotation = false
      rotation_days   = 0
    }
    "github-token" = {
      description     = "GitHub access token for ArgoCD"
      service         = "argocd"
      initial_value   = null  # Set manually
      enable_rotation = false
      rotation_days   = 0
    }
  }

  create_db_secret = true
  db_username      = "shopstream_admin"
  subnet_ids       = module.vpc.private_subnet_ids

  tags = local.common_tags
}