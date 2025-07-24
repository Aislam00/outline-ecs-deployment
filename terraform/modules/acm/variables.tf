variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

variable "create_route53_records" {
  description = "Whether to create Route53 validation records automatically"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}