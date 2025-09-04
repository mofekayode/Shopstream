module "kms" {
  source = "../../modules/kms"

  project_name = local.project_name
  environment  = local.environment
  aws_region   = var.aws_region

  tags = local.common_tags
}