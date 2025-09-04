output "secret_arns" {
  description = "Map of secret names to ARNs"
  value = {
    for k, v in aws_secretsmanager_secret.app_secrets : k => v.arn
  }
}

output "secret_names" {
  description = "Map of secret names"
  value = {
    for k, v in aws_secretsmanager_secret.app_secrets : k => v.name
  }
}

output "db_secret_arn" {
  description = "ARN of database credentials secret"
  value       = var.create_db_secret ? aws_secretsmanager_secret.db_credentials[0].arn : ""
}

output "db_secret_name" {
  description = "Name of database credentials secret"
  value       = var.create_db_secret ? aws_secretsmanager_secret.db_credentials[0].name : ""
}

output "secrets_access_policy_arn" {
  description = "ARN of the IAM policy for accessing secrets"
  value       = aws_iam_policy.secrets_access.arn
}