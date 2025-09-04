module "s3" {
  source = "../../modules/s3"

  project_name = local.project_name
  environment  = local.environment
  
  cors_origins = [
    "http://localhost:3000",
    "http://localhost:3001", 
    "http://localhost:3002",
    "http://localhost:3003"
  ]

  tags = local.common_tags
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  project_name          = local.project_name
  environment           = local.environment
  s3_bucket_name        = module.s3.static_bucket_name
  s3_bucket_domain_name = module.s3.static_bucket_domain_name

  tags = local.common_tags
}