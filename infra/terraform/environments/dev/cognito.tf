module "cognito" {
  source = "../../modules/cognito"

  project_name  = local.project_name
  environment   = local.environment
  
  callback_urls = [
    "http://localhost:3000/api/auth/callback",
    "http://localhost:3001/api/auth/callback",
    "http://localhost:3002/api/auth/callback",
    "http://localhost:3003/api/auth/callback"
  ]
  
  logout_urls = [
    "http://localhost:3000",
    "http://localhost:3001",
    "http://localhost:3002",
    "http://localhost:3003"
  ]

  tags = local.common_tags
}