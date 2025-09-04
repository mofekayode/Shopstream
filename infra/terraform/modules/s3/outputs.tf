output "media_bucket_name" {
  description = "Name of the media bucket"
  value       = aws_s3_bucket.media.id
}

output "media_bucket_arn" {
  description = "ARN of the media bucket"
  value       = aws_s3_bucket.media.arn
}

output "static_bucket_name" {
  description = "Name of the static assets bucket"
  value       = aws_s3_bucket.static.id
}

output "static_bucket_arn" {
  description = "ARN of the static assets bucket"
  value       = aws_s3_bucket.static.arn
}

output "static_bucket_domain_name" {
  description = "Domain name of the static bucket"
  value       = aws_s3_bucket.static.bucket_regional_domain_name
}

output "audit_bucket_name" {
  description = "Name of the audit logs bucket"
  value       = aws_s3_bucket.audit.id
}

output "audit_bucket_arn" {
  description = "ARN of the audit logs bucket"
  value       = aws_s3_bucket.audit.arn
}