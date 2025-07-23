# terraform/modules/ecs/main.tf

data "aws_region" "current" {}

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy for SSM parameter access
resource "aws_iam_role_policy" "ecs_task_execution_ssm_policy" {
  name = "${var.cluster_name}-ssm-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:*:*:parameter/outline/*"
        ]
      }
    ]
  })
}

# IAM role for ECS task
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.cluster_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch log group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = var.log_retention_in_days

  tags = {
    Name = "${var.service_name}-logs"
  }
}

# EFS file system for persistent storage
resource "aws_efs_file_system" "main" {
  creation_token = "${var.service_name}-efs"
  encrypted      = true

  performance_mode = "generalPurpose"
  throughput_mode  = "provisioned"
  provisioned_throughput_in_mibps = 1

  tags = {
    Name = "${var.service_name}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.subnets)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnets[count.index]
  security_groups = var.security_group_ids
}

# ECS task definition
resource "aws_ecs_task_definition" "main" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  volume {
    name = "outline-data"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.main.id
      root_directory = "/"
    }
  }

  container_definitions = jsonencode([
    {
      name  = var.service_name
      image = var.container_image
      
      essential = true
      
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "outline-data"
          containerPath = "/var/lib/outline/data"
          readOnly      = false
        }
      ]

      environment = var.environment_variables
      secrets     = var.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:${var.container_port}/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = var.service_name
  }
}

# ECS service
resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  depends_on = [aws_efs_mount_target.main]

  tags = {
    Name = var.service_name
  }
}