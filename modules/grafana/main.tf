provider "aws" {
  region = "us-east-1"
}

# Task Definitions

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:11.6.1"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }]
      environment = [
        { name = "GF_RENDERING_SERVER_URL", value = "http://renderer:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana:3000/" },
        { name = "REDIS_HOST", value = "redis" },
        { name = "REDIS_PORT", value = "6379" },
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" },
        { name = "CACHING", value = "Y" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" }
      ]
      secrets = [
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = var.postgres_secret_arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/grafana"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "grafana"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "renderer" {
  family                   = "renderer-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:3.12.5"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [{
        containerPort = 8081
        hostPort      = 8081
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/renderer"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "renderer"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "redis" {
  family                   = "redis-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "redis"
      image     = "redis:latest"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [{
        containerPort = 6379
        hostPort      = 6379
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/redis"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "redis"
        }
      }
    }
  ])
}

# ECS Services

resource "aws_ecs_service" "grafana" {
  name            = "rajesh-grafana-svc"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type    = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.grafana]
}

resource "aws_ecs_service" "renderer" {
  name            = "rajesh-renderer-svc"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count   = var.renderer_desired_count
  launch_type    = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.renderer]
}

resource "aws_ecs_service" "redis" {
  name            = "rajesh-redis-svc"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = var.redis_desired_count
  launch_type    = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.redis]
}

# Auto Scaling Targets & Policies (Grafana)

resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.grafana_max_capacity
  min_capacity       = var.grafana_min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana_cpu_policy" {
  name               = "grafana-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.grafana_target_cpu_utilization
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Auto Scaling Targets & Policies (Renderer)

resource "aws_appautoscaling_target" "renderer" {
  max_capacity       = var.renderer_max_capacity
  min_capacity       = var.renderer_min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.renderer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer_cpu_policy" {
  name               = "renderer-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer.scalable_dimension
  service_namespace  = aws_appautoscaling_target.renderer.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.renderer_target_cpu_utilization
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Auto Scaling Targets & Policies (Redis)

resource "aws_appautoscaling_target" "redis" {
  max_capacity       = var.redis_max_capacity
  min_capacity       = var.redis_min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.redis.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "redis_cpu_policy" {
  name               = "redis-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis.resource_id
  scalable_dimension = aws_appautoscaling_target.redis.scalable_dimension
  service_namespace  = aws_appautoscaling_target.redis.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.redis_target_cpu_utilization
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
