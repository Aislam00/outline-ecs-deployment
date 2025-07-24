# ACM Certificate
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  tags = merge(var.tags, {
    Name = "${var.domain_name}-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 validation records (if you're using Route53)
data "aws_route53_zone" "main" {
  count = var.create_route53_records ? 1 : 0
  
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "validation" {
  for_each = var.create_route53_records ? {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main[0].zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "main" {
  count = var.create_route53_records ? 1 : 0
  
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}