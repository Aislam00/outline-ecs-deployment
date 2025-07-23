terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "outline-ecs"
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}

# ───── Data Sources ─────
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# ───── Secrets (Random Generators) ─────
resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "random_id" "secret_key" {
  byte_length = 32
}

resource "random_id" "utils_secret" {
  byte_length = 32
}

# ───── SSM Parameters ─────
resource "aws_ssm_parameter" "db_password" {
  name  = "/outline/database/password"
  type  = "SecureString"
  value = random_password.db_password.result
}

resource "aws_ssm_parameter" "secret_key" {
  name  = "/outline/secret_key"
  type  = "SecureString"
  value = random_id.secret_key.hex
}

resource "aws_ssm_parameter" "utils_secret" {
  name  = "/outline/utils_secret"
  type  = "SecureString"
  value = random_id.utils_secret.hex
}

# ───── VPC Module ─────
module "vpc" {
  source = "./modules/vpc"

  name               = var.project_name
  cidr               = var.vpc_cidr
  azs                = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_dns_support = true
  enable_dns_hostnames = true
}

# ───── Security Groups Module ─────
module "security_groups" {
  source       = "./modules/security-groups"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

# ───── RDS Module ─────
module "rds" {
  source            = "./modules/rds"
  identifier        = "${var.project_name}-db"
  engine_version    = "15.7"
  instance_class    = var.db_instance_class
  allocated_storage = 20

  database_name     = "outline"
  database_username = "outline"
  database_password = random_password.db_password.result

  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnets
  security_group_ids = [module.security_groups.rds_sg_id]

  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  skip_final_snapshot     = true
  deletion_protection     = false
}

# ───── ElastiCache Module ─────
module "elasticache" {
  source            = "./modules/elasticache"
  cluster_id        = "${var.project_name}-redis"
  node_type         = var.cache_node_type
  num_cache_nodes   = 1

  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.security_groups.redis_sg_id]
}

# ───── ACM Module ─────
module "acm" {
  source       = "./modules/acm"
  domain_name  = var.domain_name
  zone_id      = var.route53_zone_id
  email        = "islamadam436@gmail.com"
}

# ───── ALB Module ─────
module "alb" {
  source             = "./modules/alb"
  name               = "${var.project_name}-alb"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_group_ids = [module.security_groups.alb_sg_id]
  certificate_arn    = module.acm.certificate_arn
  domain_name        = var.domain_name
}

# ───── ECS Module ─────
module "ecs" {
  source              = "./modules/ecs"
  cluster_name        = "${var.project_name}-cluster"
  service_name        = "${var.project_name}-service"

  vpc_id              = module.vpc.vpc_id
  subnets             = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]

  container_image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/outline-app:latest"
  container_port      = 3000
  container_cpu       = var.container_cpu
  container_memory    = var.container_memory
  desired_count       = var.desired_count
  target_group_arn    = module.alb.target_group_arn

  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "URL"
      value = "https://${var.domain_name}"
    },
    {
      name  = "PORT"
      value = "3000"
    },
    {
      name  = "DATABASE_URL"
      value = "postgresql://${module.rds.db_username}:${random_password.db_password.result}@${module.rds.db_endpoint}:${module.rds.db_port}/${module.rds.db_name}"
    },
    {
      name  = "REDIS_URL"
      value = "redis://${module.elasticache.primary_endpoint}:6379/0"
    },
    {
      name  = "FILE_STORAGE"
      value = "local"
    },
    {
      name  = "FILE_STORAGE_LOCAL_ROOT_DIR"
      value = "/var/lib/outline/data"
    },
    {
      name  = "FORCE_HTTPS"
      value = "true"
    },
    {
      name  = "ENFORCE_HTTPS"
      value = "true"
    }
  ]

  secrets = [
    {
      name      = "SECRET_KEY"
      valueFrom = aws_ssm_parameter.secret_key.arn
    },
    {
      name      = "UTILS_SECRET"
      valueFrom = aws_ssm_parameter.utils_secret.arn
    }
  ]
}
