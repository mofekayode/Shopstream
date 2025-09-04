module "argocd" {
  source = "../../modules/argocd"

  project_name          = local.project_name
  environment           = local.environment
  domain                = "dev.shopstream.example.com"  # Replace with your domain
  certificate_arn       = module.route53.certificate_arn
  github_org            = "mofekayode"  # Your GitHub org
  github_repo           = "Shopstream"
  target_revision       = "main"
  apps_path             = "deployments/dev/apps"
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  
  # Dev environment settings
  redis_ha              = false
  controller_replicas   = 1
  server_replicas       = 1
  repo_server_replicas  = 1
  enable_notifications  = false
  enable_rollouts       = false

  tags = local.common_tags

  depends_on = [module.eks, module.alb]
}