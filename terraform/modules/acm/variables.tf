# terraform/modules/acm/variables.tf
variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

variable "zone_id" {
  description = "Route53 zone ID (leave empty if using external DNS)"
  type        = string
  default     = ""
}

variable "email" {
  description = "Email address for certificate notifications"
  type        = string
  default     = "islamadam436@gmail.com"
}

variable "subject_alternative_names" {
  description = "Set of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}