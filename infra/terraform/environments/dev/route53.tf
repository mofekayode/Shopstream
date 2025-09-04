module "route53" {
  source = "../../modules/route53"

  domain_name               = "dev.shopstream.example.com"  # Replace with your domain
  create_zone               = true
  environment               = local.environment
  subject_alternative_names = ["*.dev.shopstream.example.com"]
  
  enable_ses           = true
  enable_ses_receiving = false
  dmarc_policy         = "none"  # Start with none for dev
  dmarc_email          = "devops@example.com"  # Replace with your email
  
  cloudfront_distribution_id = module.cloudfront.distribution_id
  cloudfront_domain_name     = module.cloudfront.distribution_domain_name
  
  enable_health_check = false  # Disable in dev to save costs

  tags = local.common_tags
}