variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "container_image" {
  description = "Docker image to run in the ECS cluster"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  type        = number
  default     = 3000
}

variable "container_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of docker containers to run"
  type        = number
  default     = 1
}

variable "target_group_arn" {
  description = "ARN of the Load Balancer target group to associate with the service"
  type        = string
}

variable "environment_variables" {
  description = "The environment variables to pass to the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "The secrets to pass to the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events"
  type        = number
  default     = 7
}