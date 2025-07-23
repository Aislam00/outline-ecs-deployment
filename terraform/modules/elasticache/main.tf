# terraform/modules/elasticache/main.tf

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.cluster_id}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.cluster_id} Cache subnet group"
  }
}

resource "aws_elasticache_parameter_group" "main" {
  family = "redis7"
  name   = "${var.cluster_id}-params"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = {
    Name = "${var.cluster_id} Cache parameter group"
  }
}

resource "aws_elasticache_cluster" "main" {
  cluster_id           = var.cluster_id
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.main.name
  port                 = var.port
  
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = var.security_group_ids

  # Remove the unsupported encryption settings for basic cluster

  tags = {
    Name = var.cluster_id
  }
}