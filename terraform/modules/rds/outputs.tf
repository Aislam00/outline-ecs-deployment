# terraform/modules/rds/outputs.tf
output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_address" {
  description = "The RDS instance hostname"
  value       = aws_db_instance.main.address
}

output "db_instance_arn" {
  description = "The RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = aws_db_instance.main.availability_zone
}

output "db_instance_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = aws_db_instance.main.hosted_zone_id
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.main.port
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = aws_db_subnet_group.main.id
}

output "db_parameter_group_id" {
  description = "The db parameter group id"
  value       = aws_db_parameter_group.main.id
}

# Convenient outputs for application configuration
output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Database username"
  value       = aws_db_instance.main.username
  sensitive   = true
}