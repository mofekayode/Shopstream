output "eks_key_id" {
  description = "KMS key ID for EKS"
  value       = aws_kms_key.eks.id
}

output "eks_key_arn" {
  description = "KMS key ARN for EKS"
  value       = aws_kms_key.eks.arn
}

output "rds_key_id" {
  description = "KMS key ID for RDS"
  value       = aws_kms_key.rds.id
}

output "rds_key_arn" {
  description = "KMS key ARN for RDS"
  value       = aws_kms_key.rds.arn
}

output "s3_key_id" {
  description = "KMS key ID for S3"
  value       = aws_kms_key.s3.id
}

output "s3_key_arn" {
  description = "KMS key ARN for S3"
  value       = aws_kms_key.s3.arn
}

output "secrets_key_id" {
  description = "KMS key ID for Secrets Manager"
  value       = aws_kms_key.secrets.id
}

output "secrets_key_arn" {
  description = "KMS key ARN for Secrets Manager"
  value       = aws_kms_key.secrets.arn
}