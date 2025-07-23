# terraform/outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS name for GoDaddy CNAME record"
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = module.alb.zone_id
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = module.elasticache.primary_endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "application_url" {
  description = "Application URL"
  value       = "https://${var.domain_name}"
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/outline-app"
}

# Instructions for GoDaddy DNS setup
output "dns_setup_instructions" {
  description = "DNS setup instructions for GoDaddy"
  value = <<EOF
Add the following CNAME record in your GoDaddy DNS management:

Record Type: CNAME
Name: tm
Value: ${module.alb.dns_name}
TTL: 600 (10 minutes)

Wait 5-10 minutes for DNS propagation, then visit: https://${var.domain_name}
EOF
}