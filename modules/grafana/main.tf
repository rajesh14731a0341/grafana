locals {
  log_retention_days = 7
}

# CloudWatch Log Groups for each service
resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana"
  retention_in_days = local.log_retention_days
}

resource "aws_cloudwatch_log_group" "renderer" {
  name              = "/ecs/renderer"
  retention_in_days = local.log_retention_days
}

resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/redis"
  retention_in_days = local.log_retention_days
}

# Grafana ECS Task Definition
resource "aws_ecs_task_definition" "grafana" {
  family                   = "rajesh-grafana-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:11.6.1"
      essential = true

      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]

      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = "admin" },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = "admin" }, # Override in production
        { name = "GF_DATABASE_TYPE", value = "postgres" },
        { name = "GF_DATABASE_HOST", value = var.postgres_host },
        { name = "GF_DATABASE_NAME", value = var.postgres_db },
        { name = "GF_DATABASE_USER", value = "postgres" },
        { name = "GF_DATABASE_SSL_MODE", value = "disable" }, # dev - no ssl
        { name = "REDIS_PATH", value = "redis:6379" },
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" },
        { name = "CACHING", value = "Y" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "GF_RENDERING_SERVER_URL", value = "http://renderer:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana:3000/" },
        { name = "GF_LOG_FILTERS", value = "rendering: debug" }
      ]

      secrets = [
        {
          name      = "GF_DATABASE_PASSWORD"
          valueFrom = var.postgres_secret_arn
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
    }
  ])
}

# Renderer ECS Task Definition
resource "aws_ecs_task_definition" "renderer" {
  family                   = "rajesh-renderer-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:3.12.5"
      essential = true

      portMappings = [{
        containerPort = 8081
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.renderer.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "renderer"
        }
      }
    }
  ])
}

# Redis ECS Task Definition
resource "aws_ecs_task_definition" "redis" {
  family                   = "rajesh-redis-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "redis"
      image     = "redis:latest"
      essential = true

      portMappings = [{
        containerPort = 6379
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.redis.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "redis"
        }
      }
    }
  ])
}

# ECS Services with autoscaling and CloudWatch metrics

# Grafana Service
resource "aws_ecs_service" "grafana" {
  name            = "rajesh-grafana-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.desired_count_grafana
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.grafana]
}

resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.max_capacity_grafana
  min_capacity       = var.min_capacity_grafana
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana_cpu" {
  name               = "grafana-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# Renderer Service
resource "aws_ecs_service" "renderer" {
  name            = "rajesh-renderer-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count   = var.desired_count_renderer
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.renderer]
}

resource "aws_appautoscaling_target" "renderer" {
  max_capacity       = var.max_capacity_renderer
  min_capacity       = var.min_capacity_renderer
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.renderer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer_cpu" {
  name               = "renderer-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer.scalable_dimension
  service_namespace  = aws_appautoscaling_target.renderer.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# Redis Service
resource "aws_ecs_service" "redis" {
  name            = "rajesh-redis-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = var.desired_count_redis
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.redis]
}

resource "aws_appautoscaling_target" "redis" {
  max_capacity       = var.max_capacity_redis
  min_capacity       = var.min_capacity_redis
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.redis.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "redis_cpu" {
  name               = "redis-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis.resource_id
  scalable_dimension = aws_appautoscaling_target.redis.scalable_dimension
  service_namespace  = aws_appautoscaling_target.redis.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
