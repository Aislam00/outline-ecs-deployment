# terraform/modules/elasticache/variables.tf
variable "cluster_id" {
  description = "Group identifier for the cache cluster"
  type        = string
}

variable "engine" {
  description = "Name of the cache engine to be used for this cache cluster"
  type        = string
  default     = "redis"
}

variable "node_type" {
  description = "The instance class used for the cache cluster"
  type        = string
  default     = "cache.t4g.micro"
}

variable "num_cache_nodes" {
  description = "The number of cache nodes that the cache cluster should have"
  type        = number
  default     = 1
}

variable "port" {
  description = "The port number on which each of the cache nodes will accept connections"
  type        = number
  default     = 6379
}

variable "subnet_ids" {
  description = "List of VPC Subnet IDs for the cache subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with this cache cluster"
  type        = list(string)
}