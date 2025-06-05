terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

###################
# ECS Task Definition and Services for Grafana, Renderer, Redis
###################

resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.name_prefix}-grafana-task"
  cpu                      = var.grafana_task_cpu
  memory                   = var.grafana_task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = var.grafana_image
      essential = true

      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]

      environment = [
        { name = "GF_DATABASE_TYPE", value = "postgres" },
        { name = "GF_DATABASE_HOST", value = var.postgres_host },
        { name = "GF_DATABASE_NAME", value = var.postgres_db },
        { name = "GF_DATABASE_USER", value = var.postgres_user },
        { name = "GF_DATABASE_PASSWORD_SECRET_ARN", value = var.postgres_password_secret_arn },
        { name = "GF_RENDERING_SERVER_URL", value = "http://renderer:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana:3000/" },
        { name = "GF_LOG_FILTERS", value = "rendering:debug" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "REDIS_PATH", value = var.redis_host },
        { name = "REDIS_DB", value = var.redis_db },
        { name = "REDIS_CACHETIME", value = var.redis_cachetime },
        { name = "CACHING", value = var.caching },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.cloudwatch_log_group,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "grafana"
        }
      }

      dependsOn = [
        {
          containerName = "renderer"
          condition     = "START"
        },
        {
          containerName = "redis"
          condition     = "START"
        }
      ]
    },
    {
      name      = "renderer"
      image     = var.renderer_image
      essential = true

      portMappings = [{
        containerPort = 8081
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.cloudwatch_log_group,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "renderer"
        }
      }
    },
    {
      name      = "redis"
      image     = var.redis_image
      essential = true

      portMappings = [{
        containerPort = 6379
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.cloudwatch_log_group,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "redis"
        }
      }
    }
  ])
}

###################
# ECS Services
###################

resource "aws_ecs_service" "grafana" {
  name            = "${var.name_prefix}-grafana-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  depends_on = [aws_cloudwatch_log_group.grafana]

  lifecycle {
    ignore_changes = [task_definition]
  }
}

###################
# CloudWatch Log Groups
###################

resource "aws_cloudwatch_log_group" "grafana" {
  name              = var.cloudwatch_log_group
  retention_in_days = 14
}

###################
# AutoScaling
###################

resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.grafana_autoscaling_max
  min_capacity       = var.grafana_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana_cpu" {
  name               = "${var.name_prefix}-grafana-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.grafana_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

###################
# Repeat ECS Service & AutoScaling for Renderer & Redis
###################

resource "aws_ecs_service" "renderer" {
  name            = "${var.name_prefix}-renderer-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.renderer_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_appautoscaling_target" "renderer" {
  max_capacity       = var.renderer_autoscaling_max
  min_capacity       = var.renderer_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.renderer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer_cpu" {
  name               = "${var.name_prefix}-renderer-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer.scalable_dimension
  service_namespace  = aws_appautoscaling_target.renderer.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.renderer_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_ecs_service" "redis" {
  name            = "${var.name_prefix}-redis-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.redis_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_appautoscaling_target" "redis" {
  max_capacity       = var.redis_autoscaling_max
  min_capacity       = var.redis_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.redis.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "redis_cpu" {
  name               = "${var.name_prefix}-redis-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis.resource_id
  scalable_dimension = aws_appautoscaling_target.redis.scalable_dimension
  service_namespace  = aws_appautoscaling_target.redis.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.redis_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
