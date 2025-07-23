# terraform/modules/acm/main.tf

resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.domain_name
    Email = var.email
  }
}

# Note: Since using external DNS (GoDaddy), we cannot auto-validate
# You'll need to manually add the DNS validation records to GoDaddy

output "certificate_validation_options" {
  description = "Certificate validation options for manual DNS setup"
  value = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
}

# For GoDaddy DNS, we'll wait manually or use a timer
resource "time_sleep" "wait_for_certificate" {
  depends_on = [aws_acm_certificate.main]
  
  create_duration = "30s"
}

# We'll assume certificate is validated (since we can't auto-validate with GoDaddy)
# In production, you would manually add the DNS records and then this would work
locals {
  certificate_arn = aws_acm_certificate.main.arn
}