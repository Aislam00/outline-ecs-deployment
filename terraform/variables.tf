# terraform/variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "475641479654"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "outline"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "tm.integratepro.online"
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for the domain"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "container_cpu" {
  description = "CPU units for the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "cache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t4g.micro"
}