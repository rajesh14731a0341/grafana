resource "aws_service_discovery_private_dns_namespace" "cloudmap_namespace" {
  name        = "grafana.local"
  description = "Private namespace for Grafana ECS services"
  vpc         = var.vpc_id
}

# ECS service discovery service for all services
resource "aws_service_discovery_service" "grafana" {
  name = "grafana"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cloudmap_namespace.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "renderer" {
  name = "renderer"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cloudmap_namespace.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "redis" {
  name = "redis"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cloudmap_namespace.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

locals {
  grafana_env = [
    { name = "REDIS_PATH", value = "redis.grafana.local:6379" },
    { name = "REDIS_DB", value = "1" },
    { name = "REDIS_CACHETIME", value = "12000" },
    { name = "CACHING", value = "Y" },
    { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
    { name = "GF_RENDERING_SERVER_URL", value = "http://renderer.grafana.local:8081/render" },
    { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana.grafana.local:3000/" },
    { name = "GF_LOG_FILTERS", value = "rendering: debug" },
    { name = "GF_DATABASE_TYPE", value = "postgres" },
    { name = "GF_DATABASE_HOST", value = var.db_endpoint },
    { name = "GF_DATABASE_PORT", value = tostring(var.db_port) },
    { name = "GF_DATABASE_NAME", value = var.db_name },
    { name = "GF_DATABASE_USER", value = var.db_username },
    { name = "GF_DATABASE_SSL_MODE", value = "require" }
  ]

  renderer_env = [
    { name = "NODE_ENV", value = "production" }
  ]

  redis_env = [
    { name = "ALLOW_EMPTY_PASSWORD", value = "yes" }
  ]
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana"
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "grafana"
    image     = "grafana/grafana-enterprise:11.6.1"
    essential = true
    portMappings = [
      {
        containerPort = 3000
        protocol      = "tcp"
      }
    ]
    environment = local.grafana_env
    secrets = [
      {
        name      = "GF_DATABASE_PASSWORD"
        valueFrom = var.db_secret_arn
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/grafana"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "grafana"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "renderer" {
  family                   = "renderer"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "renderer"
    image     = "grafana/grafana-image-renderer:3.12.5"
    essential = true
    portMappings = [
      {
        containerPort = 8081
        protocol      = "tcp"
      }
    ]
    environment = local.renderer_env
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8081/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/renderer"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "renderer"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "redis" {
  family                   = "redis"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "redis"
    image     = "redis:7-alpine"
    essential = true
    portMappings = [
      {
        containerPort = 6379
        protocol      = "tcp"
      }
    ]
    environment = local.redis_env
    healthCheck = {
      command     = ["CMD", "redis-cli", "ping"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/redis"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "redis"
      }
    }
  }])
}

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
  service_registries {
    registry_arn = aws_service_discovery_service.grafana.arn
  }
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}

resource "aws_ecs_service" "renderer" {
  name            = "renderer"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count   = var.renderer_desired_count
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
  service_registries {
    registry_arn = aws_service_discovery_service.renderer.arn
  }
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}

resource "aws_ecs_service" "redis" {
  name            = "redis"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = var.redis_desired_count
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
  service_registries {
    registry_arn = aws_service_discovery_service.redis.arn
  }
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}

resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.grafana_autoscaling_max
  min_capacity       = var.grafana_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana_cpu" {
  name               = "grafana-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.grafana_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "renderer" {
  max_capacity       = var.renderer_autoscaling_max
  min_capacity       = var.renderer_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.renderer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer_cpu" {
  name               = "renderer-cpu"
