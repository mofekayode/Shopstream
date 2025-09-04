module "eks" {
  source = "../../modules/eks"

  project_name       = local.project_name
  environment        = local.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  kms_key_arn        = module.kms.eks_key_arn

  # Dev environment sizing
  instance_types   = ["t3.small"]
  desired_capacity = 1
  min_capacity     = 1
  max_capacity     = 2

  tags = local.common_tags
}