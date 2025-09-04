output "users_table_name" {
  description = "Name of the users table"
  value       = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  description = "ARN of the users table"
  value       = aws_dynamodb_table.users.arn
}

output "dynamodb_access_role_arn" {
  description = "ARN of the IAM role for DynamoDB access"
  value       = aws_iam_role.dynamodb_access.arn
}

output "dynamodb_access_policy_arn" {
  description = "ARN of the IAM policy for DynamoDB access"
  value       = aws_iam_policy.dynamodb_access.arn
}