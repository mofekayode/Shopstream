module "ecr" {
  source = "../../modules/ecr"

  project_name                = local.project_name
  environment                 = local.environment
  max_image_count            = 10  # Keep only 10 images in dev
  untagged_image_expiry_days = 3   # Clean up untagged images faster in dev
  enable_enhanced_scanning   = false  # Save costs in dev

  tags = local.common_tags
}