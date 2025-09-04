resource "aws_dynamodb_table" "users" {
  name           = "${var.project_name}-${var.environment}-users"
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  global_secondary_index {
    name            = "email-index"
    hash_key        = "email"
    projection_type = "ALL"
    read_capacity   = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
    write_capacity  = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  ttl {
    enabled        = var.enable_ttl
    attribute_name = "ttl"
  }

  stream_specification {
    stream_enabled   = var.enable_streams
    stream_view_type = var.stream_view_type
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-users"
      Environment = var.environment
      Service     = "identity"
    }
  )
}

# Note: Sessions and token management are handled by AWS Cognito
# We only need the users table to store additional user metadata

# IAM Role for Lambda/ECS to access DynamoDB
resource "aws_iam_role" "dynamodb_access" {
  name = "${var.project_name}-${var.environment}-dynamodb-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ecs-tasks.amazonaws.com", "lambda.amazonaws.com", "eks.amazonaws.com"]
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "dynamodb_access" {
  name        = "${var.project_name}-${var.environment}-dynamodb-access"
  description = "Policy for accessing DynamoDB tables"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTable",
          "dynamodb:ConditionCheckItem"
        ]
        Resource = [
          aws_dynamodb_table.users.arn,
          "${aws_dynamodb_table.users.arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_arn != "" ? [var.kms_key_arn] : ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  policy_arn = aws_iam_policy.dynamodb_access.arn
  role       = aws_iam_role.dynamodb_access.name
}

# Auto-scaling for provisioned capacity
resource "aws_appautoscaling_target" "users_read" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_read_capacity
  min_capacity       = var.read_capacity
  resource_id        = "table/${aws_dynamodb_table.users.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "users_read" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  name               = "${var.project_name}-${var.environment}-users-read-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.users_read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.users_read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.users_read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_appautoscaling_target" "users_write" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_write_capacity
  min_capacity       = var.write_capacity
  resource_id        = "table/${aws_dynamodb_table.users.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "users_write" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  name               = "${var.project_name}-${var.environment}-users-write-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.users_write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.users_write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.users_write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70.0
  }
}