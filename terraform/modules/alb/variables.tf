variable "name" {
  description = "The name of the load balancer"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the LB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to assign to the LB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "The ARN of the default SSL server certificate"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "target_port" {
  description = "The port on which targets receive traffic"
  type        = number
  default     = 3000
}

variable "target_protocol" {
  description = "The protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "The destination for the health check request"
  type        = string
  default     = "/"
}

variable "health_check_healthy_threshold" {
  description = "The number of consecutive health check successes required before considering an unhealthy target healthy"
  type        = number
  default     = 2
}

variable "health_check_interval" {
  description = "The amount of time, in seconds, between health checks of an individual target"
  type        = number
  default     = 30
}

variable "health_check_
