data "aws_route53_zone" "main" {
  count = var.create_zone ? 0 : 1
  name  = var.domain_name
}

resource "aws_route53_zone" "main" {
  count = var.create_zone ? 1 : 0
  name  = var.domain_name

  tags = merge(
    var.tags,
    {
      Name        = var.domain_name
      Environment = var.environment
    }
  )
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
}

# ACM Certificate
resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name        = var.domain_name
      Environment = var.environment
    }
  )
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.zone_id
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# SES Domain Verification
resource "aws_ses_domain_identity" "main" {
  count  = var.enable_ses ? 1 : 0
  domain = var.domain_name
}

resource "aws_route53_record" "ses_verification" {
  count   = var.enable_ses ? 1 : 0
  zone_id = local.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = 600
  records = [aws_ses_domain_identity.main[0].verification_token]
}

resource "aws_ses_domain_identity_verification" "main" {
  count  = var.enable_ses ? 1 : 0
  domain = aws_ses_domain_identity.main[0].id

  depends_on = [aws_route53_record.ses_verification]
}

# DKIM Records for SES
resource "aws_ses_domain_dkim" "main" {
  count  = var.enable_ses ? 1 : 0
  domain = aws_ses_domain_identity.main[0].domain
}

resource "aws_route53_record" "dkim" {
  count   = var.enable_ses ? 3 : 0
  zone_id = local.zone_id
  name    = "${element(aws_ses_domain_dkim.main[0].dkim_tokens, count.index)}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = 600
  records = ["${element(aws_ses_domain_dkim.main[0].dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# SPF Record
resource "aws_route53_record" "spf" {
  count   = var.enable_ses ? 1 : 0
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com ~all"]
}

# DMARC Record
resource "aws_route53_record" "dmarc" {
  count   = var.enable_ses ? 1 : 0
  zone_id = local.zone_id
  name    = "_dmarc.${var.domain_name}"
  type    = "TXT"
  ttl     = 600
  records = ["v=DMARC1; p=${var.dmarc_policy}; rua=mailto:${var.dmarc_email}; ruf=mailto:${var.dmarc_email}; sp=${var.dmarc_policy}; aspf=s; adkim=s;"]
}

# MX Record for receiving emails
resource "aws_route53_record" "mx" {
  count   = var.enable_ses && var.enable_ses_receiving ? 1 : 0
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = 600
  records = ["10 inbound-smtp.${data.aws_region.current.name}.amazonaws.com"]
}

data "aws_region" "current" {}

# CloudFront Alias Record
resource "aws_route53_record" "cloudfront" {
  count   = var.cloudfront_distribution_id != "" ? 1 : 0
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront_www" {
  count   = var.cloudfront_distribution_id != "" && var.create_www_record ? 1 : 0
  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# Health Check
resource "aws_route53_health_check" "main" {
  count = var.enable_health_check ? 1 : 0

  fqdn              = var.health_check_domain != "" ? var.health_check_domain : var.domain_name
  port              = var.health_check_port
  type              = var.health_check_protocol
  resource_path     = var.health_check_path
  failure_threshold = var.health_check_failure_threshold
  request_interval  = var.health_check_interval

  tags = merge(
    var.tags,
    {
      Name        = "${var.domain_name}-health-check"
      Environment = var.environment
    }
  )
}