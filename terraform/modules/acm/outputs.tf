# terraform/modules/acm/outputs.tf
output "certificate_arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_domain_name" {
  description = "The domain name for which the certificate is issued"
  value       = aws_acm_certificate.main.domain_name
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.main.status
}

output "domain_validation_options" {
  description = "Set of domain validation objects which can be used to complete certificate validation"
  value       = aws_acm_certificate.main.domain_validation_options
}