output "zone_id" {
  description = "The hosted zone ID"
  value       = local.zone_id
}

output "zone_name" {
  description = "The hosted zone name"
  value       = var.domain_name
}

output "name_servers" {
  description = "Name servers for the hosted zone"
  value       = var.create_zone ? aws_route53_zone.main[0].name_servers : []
}

output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_domain_validation_options" {
  description = "Domain validation options for the certificate"
  value       = aws_acm_certificate.main.domain_validation_options
}

output "ses_domain_identity_arn" {
  description = "ARN of the SES domain identity"
  value       = var.enable_ses ? aws_ses_domain_identity.main[0].arn : ""
}

output "ses_verification_token" {
  description = "SES domain verification token"
  value       = var.enable_ses ? aws_ses_domain_identity.main[0].verification_token : ""
  sensitive   = true
}

output "dkim_tokens" {
  description = "DKIM tokens for the domain"
  value       = var.enable_ses ? aws_ses_domain_dkim.main[0].dkim_tokens : []
}