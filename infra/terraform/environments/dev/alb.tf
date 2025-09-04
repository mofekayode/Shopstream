module "alb" {
  source = "../../modules/alb"

  project_name              = local.project_name
  environment               = local.environment
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  certificate_arn           = module.route53.certificate_arn
  enable_deletion_protection = false  # Allow deletion in dev
  log_retention_days        = 7       # Shorter retention in dev
  eks_oidc_provider_arn     = module.eks.oidc_provider_arn

  tags = local.common_tags
}