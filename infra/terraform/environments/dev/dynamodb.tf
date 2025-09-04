module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name                  = local.project_name
  environment                   = local.environment
  billing_mode                  = "PAY_PER_REQUEST"  # On-demand for dev
  enable_point_in_time_recovery = true
  kms_key_arn                   = module.kms.dynamodb_key_arn
  enable_streams                = false  # Enable when needed for CDC
  
  tags = local.common_tags
}