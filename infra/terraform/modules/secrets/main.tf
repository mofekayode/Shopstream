resource "aws_secretsmanager_secret" "app_secrets" {
  for_each = var.secrets

  name                    = "${var.project_name}/${var.environment}/${each.key}"
  description             = each.value.description
  recovery_window_in_days = var.recovery_window_days
  kms_key_id              = var.kms_key_id

  replica {
    region = var.replica_region
    kms_key_id = var.replica_kms_key_id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}/${var.environment}/${each.key}"
      Environment = var.environment
      Service     = each.value.service
    }
  )
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  for_each = { for k, v in var.secrets : k => v if v.initial_value != null }

  secret_id     = aws_secretsmanager_secret.app_secrets[each.key].id
  secret_string = jsonencode(each.value.initial_value)

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret_rotation" "app_secrets" {
  for_each = { for k, v in var.secrets : k => v if v.enable_rotation }

  secret_id           = aws_secretsmanager_secret.app_secrets[each.key].id
  rotation_lambda_arn = aws_lambda_function.rotation[each.key].arn

  rotation_rules {
    automatically_after_days = each.value.rotation_days
  }
}

# Database credentials secret
resource "aws_secretsmanager_secret" "db_credentials" {
  count = var.create_db_secret ? 1 : 0

  name                    = "${var.project_name}/${var.environment}/rds/master"
  description             = "RDS master credentials"
  recovery_window_in_days = var.recovery_window_days
  kms_key_id              = var.kms_key_id

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}/${var.environment}/rds/master"
      Environment = var.environment
      Type        = "database"
    }
  )
}

resource "random_password" "db_password" {
  count = var.create_db_secret ? 1 : 0

  length  = 32
  special = true
  override_special = "!#$%&*()-_=+[]{}:?"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  count = var.create_db_secret ? 1 : 0

  secret_id = aws_secretsmanager_secret.db_credentials[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password[0].result
    engine   = "postgres"
    host     = ""  # To be updated when RDS is created
    port     = 5432
    dbname   = "${var.project_name}_${var.environment}"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# IAM role for Lambda rotation function
resource "aws_iam_role" "rotation" {
  for_each = { for k, v in var.secrets : k => v if v.enable_rotation }

  name = "${var.project_name}-${var.environment}-rotation-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "rotation" {
  for_each = { for k, v in var.secrets : k => v if v.enable_rotation }

  name = "rotation-policy"
  role = aws_iam_role.rotation[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = aws_secretsmanager_secret.app_secrets[each.key].arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetRandomPassword"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_id != "" ? var.kms_key_id : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rotation_vpc" {
  for_each = { for k, v in var.secrets : k => v if v.enable_rotation }

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.rotation[each.key].name
}

# Lambda rotation function (placeholder - actual implementation needed)
resource "aws_lambda_function" "rotation" {
  for_each = { for k, v in var.secrets : k => v if v.enable_rotation }

  filename      = "${path.module}/rotation_lambda.zip"
  function_name = "${var.project_name}-${var.environment}-rotation-${each.key}"
  role          = aws_iam_role.rotation[each.key].arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 30

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-rotation-${each.key}"
      Environment = var.environment
    }
  )

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_permission" "rotation" {
  for_each = { for k, v in var.secrets : k => v if v.enable_rotation }

  statement_id  = "AllowSecretsManagerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotation[each.key].function_name
  principal     = "secretsmanager.amazonaws.com"
}

data "aws_region" "current" {}

# IAM policy for accessing secrets from EKS
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.project_name}-${var.environment}-secrets-access"
  description = "Policy for accessing Secrets Manager secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:*:secret:${var.project_name}/${var.environment}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_id != "" ? var.kms_key_id : "*"
      }
    ]
  })

  tags = var.tags
}

# Create a placeholder rotation lambda zip
resource "null_resource" "rotation_lambda_zip" {
  provisioner "local-exec" {
    command = <<EOF
cat > /tmp/index.py << 'SCRIPT'
import boto3
import json

def handler(event, context):
    # Placeholder rotation logic
    # Actual implementation would handle secret rotation
    service_client = boto3.client('secretsmanager')
    
    arn = event['SecretId']
    token = event['Token']
    step = event['Step']
    
    if step == "createSecret":
        # Generate new secret
        pass
    elif step == "setSecret":
        # Set new secret in service
        pass
    elif step == "testSecret":
        # Test new secret
        pass
    elif step == "finishSecret":
        # Mark new secret as current
        pass
        
    return {"statusCode": 200}
SCRIPT

cd /tmp && zip -q rotation_lambda.zip index.py
cp /tmp/rotation_lambda.zip ${path.module}/
EOF
  }
}