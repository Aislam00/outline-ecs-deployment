# terraform/modules/elasticache/outputs.tf
output "cluster_id" {
  description = "The cache cluster ID"
  value       = aws_elasticache_cluster.main.cluster_id
}

output "cluster_address" {
  description = "The DNS name of the cache cluster without the port appended"
  value       = aws_elasticache_cluster.main.cluster_address
}

output "cluster_arn" {
  description = "The ARN of the ElastiCache Cluster"
  value       = aws_elasticache_cluster.main.arn
}

output "cache_nodes" {
  description = "List of node objects including id, address, port and availability_zone"
  value       = aws_elasticache_cluster.main.cache_nodes
}

output "primary_endpoint" {
  description = "The primary endpoint for the cache cluster"
  value       = aws_elasticache_cluster.main.cluster_address
}

output "port" {
  description = "The port number on which each of the cache nodes will accept connections"
  value       = aws_elasticache_cluster.main.port
}