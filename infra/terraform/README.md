# Shopstream Infrastructure

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured (`aws configure`)
3. **Terraform** >= 1.5.0 installed
4. **AWS credentials** configured

## Quick Start

### 1. Deploy Development Environment

```bash
cd infra/terraform/environments/dev

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the infrastructure
terraform apply
```

### 2. Capture Outputs

After deployment, capture the outputs for your `.env` file:

```bash
terraform output -json > outputs.json
```

Key outputs:
- `cognito_user_pool_id` - Add to COGNITO_USER_POOL_ID
- `cognito_client_id` - Add to COGNITO_CLIENT_ID
- `region` - Add to AWS_REGION

### 3. Create `.env` File

Create `.env` in the root directory:

```bash
# AWS Configuration
AWS_REGION=us-east-1

# Cognito Configuration  
COGNITO_USER_POOL_ID=<from terraform output>
COGNITO_CLIENT_ID=<from terraform output>

# Service Configuration
NODE_ENV=development
LOG_LEVEL=info
```

## Infrastructure Components

### Currently Deployed (Milestone 0)

- **AWS Cognito**
  - User Pool with email/password auth
  - MFA optional
  - Email verification required
  - Custom roles attribute

### Coming Soon

- **EKS Cluster** (Milestone 0)
- **RDS PostgreSQL** (Milestone 2)
- **DynamoDB Tables** (Milestone 1)
- **S3 Buckets** (Milestone 0)
- **CloudFront** (Milestone 0)

## Environments

- `dev/` - Development environment (local testing)
- `staging/` - Staging environment (coming soon)
- `prod/` - Production environment (coming soon)

## Cost Management

Current dev environment costs (approximate):
- Cognito: Free tier (50,000 MAUs free)
- Total: ~$0/month for development

## Destroy Infrastructure

To tear down the infrastructure:

```bash
cd infra/terraform/environments/dev
terraform destroy
```

## Troubleshooting

### Terraform State Issues
If you encounter state issues:
```bash
terraform init -reconfigure
```

### AWS Credentials
Ensure your AWS credentials are configured:
```bash
aws sts get-caller-identity
```

### Cognito Domain Already Exists
If the Cognito domain name is taken, update the domain in `cognito.tf`