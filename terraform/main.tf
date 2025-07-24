terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  name_prefix         = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  
  tags = local.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"
  
  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  
  tags = local.common_tags
}

# ACM Certificate Module
module "acm" {
  source = "./modules/acm"
  
  domain_name = var.domain_name
  
  tags = local.common_tags
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"
  
  name_prefix        = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_security_group_id
  certificate_arn   = module.acm.certificate_arn
  
  tags = local.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  name_prefix         = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.rds_security_group_id
  
  db_instance_class = var.db_instance_class
  db_name          = var.db_name
  db_username      = var.db_username
  
  tags = local.common_tags
}

# ElastiCache (Redis) Module
module "elasticache" {
  source = "./modules/elasticache"
  
  name_prefix         = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.redis_security_group_id
  
  node_type = var.redis_node_type
  
  tags = local.common_tags
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"
  
  name_prefix         = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.ecs_security_group_id
  
  # Load balancer
  target_group_arn = module.alb.target_group_arn
  
  # Database
  database_url = "postgres://${var.db_username}:${module.rds.db_password}@${module.rds.db_endpoint}/${var.db_name}"
  redis_url    = "redis://${module.elasticache.redis_endpoint}:6379"
  
  # Application settings
  outline_image    = var.outline_image
  outline_port     = var.outline_port
  desired_count    = var.desired_count
  cpu             = var.cpu
  memory          = var.memory
  
  # Environment variables
  secret_key      = var.secret_key
  utils_secret    = var.utils_secret
  domain_name     = var.domain_name
  
  tags = local.common_tags
  
  depends_on = [
    module.rds,
    module.elasticache,
    module.alb
  ]
}