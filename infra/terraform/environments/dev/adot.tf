module "adot" {
  source = "../../modules/adot"

  project_name          = local.project_name
  environment           = local.environment
  cluster_name          = module.eks.cluster_id
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  collector_replicas    = 1  # Single replica in dev
  collector_cpu_limit   = "500m"  # Lower resources in dev
  collector_memory_limit = "1Gi"
  log_retention_days    = 3
  kms_key_id           = module.kms.cloudwatch_key_arn
  enable_prometheus    = false  # Disable in dev to save resources

  tags = local.common_tags

  depends_on = [module.eks]
}