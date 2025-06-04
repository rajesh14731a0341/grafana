variable "ecs_cluster_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "efs_access_point_id" {}
variable "efs_file_system_id" {}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "grafana_task" {
  family                   = "grafana-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  volume {
    name = "grafana-var-lib"
    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "DISABLED"
      }
      root_directory = "/"  # Root of the EFS
    }
  }

  volume {
    name = "grafana-provisioning"
    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "DISABLED"
      }
      root_directory = "/provisioning"
    }
  }

  volume {
    name = "grafana-config"
    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "DISABLED"
      }
      root_directory = "/config"
    }
  }

  volume {
    name = "grafana-plugins"
    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "DISABLED"
      }
      root_directory = "/plugins"
    }
  }

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:11.6.1"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "REDIS_PATH", value = "redis:6379" },
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" },
        { name = "CACHING", value = "Y" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "GF_RENDERING_SERVER_URL", value = "http://renderer:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana:3000/" },
        { name = "GF_LOG_FILTERS", value = "rendering:debug" }
      ]
      mountPoints = [
        {
          sourceVolume  = "grafana-var-lib"
          containerPath = "/var/lib/grafana"
          readOnly      = false
        },
        {
          sourceVolume  = "grafana-provisioning"
          containerPath = "/etc/grafana/provisioning"
          readOnly      = false
        },
        {
          sourceVolume  = "grafana-config"
          containerPath = "/etc/grafana"
          readOnly      = false
        },
        {
          sourceVolume  = "grafana-plugins"
          containerPath = "/var/lib/grafana/plugins"
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "grafana"
        }
      }
    },
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:3.12.5"
      essential = true
      portMappings = [
        {
          containerPort = 8081
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "renderer"
        }
      }
    },
    {
      name      = "redis"
      image     = "redis:7.0-alpine"
      essential = true
      portMappings = [
        {
          containerPort = 6379
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "redis"
        }
      }
    }
  ])
}
