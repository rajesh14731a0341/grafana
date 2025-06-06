# Cloud Map private DNS namespace for service discovery
resource "aws_service_discovery_private_dns_namespace" "cloud_map_ns" {
  name        = "grafana.local"
  description = "Private DNS namespace for Grafana ECS services"
  vpc         = var.vpc_id
}

# ECS Task Definitions

locals {
  # Docker images for services
  grafana_image  = "grafana/grafana-enterprise:11.6.1"
  renderer_image = "grafana/grafana-image-renderer:3.12.5"
  redis_image    = "redis:latest"
}

# Secrets Manager ARN to container secrets
# Grafana DB secret will be mounted as environment variables by fetching keys username, password, dbname, host

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = var.db_secret_arn
}

# Grafana Task Definition
resource "aws_ecs_task_definition" "grafana" {
  family                   = "rajesh-grafana-task"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = local.grafana_image
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "REDIS_PATH", value = "redis.grafana.local:6379" },
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" },
        { name = "CACHING", value = "Y" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "GF_RENDERING_SERVER_URL", value = "http://renderer.grafana.local:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana.grafana.local:3000/" },
        { name = "GF_LOG_FILTERS", value = "rendering: debug" }
      ]
      secrets = [
        {
          name      = "GF_DATABASE_USER"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "GF_DATABASE_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        },
        {
          name      = "GF_DATABASE_NAME"
          valueFrom = "${var.db_secret_arn}:dbname::"
        },
        {
          name      = "GF_DATABASE_HOST"
          valueFrom = "${var.db_secret_arn}:host::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/rajesh-grafana"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana"
        }
      }
    }
  ])
}

# Renderer Task Definition
resource "aws_ecs_task_definition" "renderer" {
  family                   = "rajesh-renderer-task"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "renderer"
      image     = local.renderer_image
      cpu       = 256
      memory    = 512
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
          awslogs-group         = "/ecs/rajesh-renderer"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "renderer"
        }
      }
    }
  ])
}

# Redis Task Definition
resource "aws_ecs_task_definition" "redis" {
  family                   = "rajesh-redis-task"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "redis"
      image     = local.redis_image
      cpu       = 256
      memory    = 512
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
          awslogs-group         = "/ecs/rajesh-redis"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "redis"
        }
      }
    }
  ])
}

# ECS Services

resource "aws_ecs_service" "grafana" {
  name            = "rajesh-grafana-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.grafana.arn
  }

  depends_on = [aws_service_discovery_service.grafana]
}

resource "aws_ecs_service" "renderer" {
  name            = "rajesh-renderer-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count   = var.renderer_desired_count
  launch_type     = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.renderer.arn
  }

  depends_on = [aws_service_discovery_service.renderer]
}

resource "aws_ecs_service" "redis" {
  name            = "rajesh-redis-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = var.redis_desired_count
  launch_type     = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.redis.arn
  }

  depends_on = [aws_service_discovery_service.redis]
}

# Cloud Map Service Registrations

resource "aws_service_discovery_service" "grafana" {
  name = "grafana"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cloud_map_ns.id
    dns_records {
      ttl  = 10
      type = "A"
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
    namespace_id = aws_service_discovery_private_dns_namespace.cloud_map_ns.id
    dns_records {
      ttl  = 10
      type = "A"
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
    namespace_id = aws_service_discovery_private_dns_namespace.cloud_map_ns.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

# Autoscaling for Grafana
resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.grafana_autoscaling_max
  min_capacity       = var.grafana_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana_cpu" {
  name               = "grafana-cpu-policy"
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

# Autoscaling for Renderer
resource "aws_appautoscaling_target" "renderer" {
  max_capacity       = var.renderer_autoscaling_max
  min_capacity       = var.renderer_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.renderer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer_cpu" {
  name               = "renderer-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer.scalable_dimension
  service_namespace  = aws_appautoscaling_target.renderer.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.renderer_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Autoscaling for Redis
resource "aws_appautoscaling_target" "redis" {
  max_capacity       = var.redis_autoscaling_max
  min_capacity       = var.redis_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.redis.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "redis_cpu" {
  name               = "redis-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis.resource_id
  scalable_dimension = aws_appautoscaling_target.redis.scalable_dimension
  service_namespace  = aws_appautoscaling_target.redis.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.redis_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
