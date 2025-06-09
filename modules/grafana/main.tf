# Cloud Map Private DNS Namespace
resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "grafana-ecs.local" # Or a name of your choice
  vpc  = var.vpc_id
}

# Grafana Task Definition
resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  cpu                      = 1024 # Example: 1 vCPU
  memory                   = 2048 # Example: 2GB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name        = "grafana"
      image       = "grafana/grafana-enterprise:11.6.1"
      cpu         = 1024
      memory      = 2048
      essential   = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
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
        { name = "GF_LOG_FILTERS", value = "rendering: debug" },
        # PostgreSQL connection details from Secrets Manager
        { name = "GF_DATABASE_TYPE", value = "postgres" },
        { name = "GF_DATABASE_HOST", value = "${var.db_endpoint}:${var.db_port}" },
        { name = "GF_DATABASE_NAME", value = var.db_name },
        { name = "GF_DATABASE_USER", value = var.db_username },
        { name = "GF_DATABASE_SSL_MODE", value = "require" } # Adjust as per your RDS SSL configuration
      ]
      secrets = [
        {
          name      = "GF_DATABASE_PASSWORD"
          valueFrom = "${var.db_secret_arn}:grafana/psql/rajesh-password-7YOPwB::password" # Extract 'password' field from plain text secret
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

# Renderer Task Definition
resource "aws_ecs_task_definition" "renderer" {
  family                   = "renderer-task"
  cpu                      = 512 # Example: 0.5 vCPU
  memory                   = 1024 # Example: 1GB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name        = "renderer"
      image       = "grafana/grafana-image-renderer:3.12.5"
      cpu         = 512
      memory      = 1024
      essential   = true
      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
        }
      ]
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

# Redis Task Definition
resource "aws_ecs_task_definition" "redis" {
  family                   = "redis-task"
  cpu                      = 256 # Example: 0.25 vCPU
  memory                   = 512 # Example: 0.5GB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name        = "redis"
      image       = "redis:latest"
      cpu         = 256
      memory      = 512
      essential   = true
      portMappings = [
        {
          containerPort = 6379
          hostPort      = 6379
        }
      ]
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

# Grafana ECS Service
resource "aws_ecs_service" "grafana" {
  name            = "rajesh-grafana-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true # Or false if using NAT Gateway
  }

  force_new_deployment = true

  # CloudWatch Log Group for Grafana
  depends_on = [
    aws_cloudwatch_log_group.grafana
  ]
}

# Renderer ECS Service
resource "aws_ecs_service" "renderer" {
  name            = "rajesh-renderer-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count   = var.renderer_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true # Or false if using NAT Gateway
  }

  service_registries {
    registry_arn = aws_service_discovery_service.renderer.arn
  }

  force_new_deployment = true

  # CloudWatch Log Group for Renderer
  depends_on = [
    aws_cloudwatch_log_group.renderer
  ]
}

# Redis ECS Service
resource "aws_ecs_service" "redis" {
  name            = "rajesh-redis-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = var.redis_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true # Or false if using NAT Gateway
  }

  service_registries {
    registry_arn = aws_service_discovery_service.redis.arn
  }

  force_new_deployment = true

  # CloudWatch Log Group for Redis
  depends_on = [
    aws_cloudwatch_log_group.redis
  ]
}

# Cloud Map Service for Renderer
resource "aws_service_discovery_service" "renderer" {
  name        = "renderer"
  namespace_id = aws_service_discovery_private_dns_namespace.main.id
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

# Cloud Map Service for Redis
resource "aws_service_discovery_service" "redis" {
  name        = "redis"
  namespace_id = aws_service_discovery_private_dns_namespace.main.id
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}


# CloudWatch Log Group for Grafana
resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana"
  retention_in_days = 7 # Or your desired retention period
}

# CloudWatch Log Group for Renderer
resource "aws_cloudwatch_log_group" "renderer" {
  name              = "/ecs/renderer"
  retention_in_days = 7 # Or your desired retention period
}

# CloudWatch Log Group for Redis
resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/redis"
  retention_in_days = 7 # Or your desired retention period
}


# Grafana Autoscaling Target
resource "aws_applicationautoscaling_target" "grafana" {
  service_namespace  = "ecs"
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.grafana_autoscaling_min
  max_capacity       = var.grafana_autoscaling_max
}

# Grafana Autoscaling Policy (CPU)
resource "aws_applicationautoscaling_policy" "grafana_cpu" {
  name               = "grafana-cpu-autoscaling"
  service_namespace  = "ecs"
  resource_id        = aws_applicationautoscaling_target.grafana.resource_id
  scalable_dimension = aws_applicationautoscaling_target.grafana.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.grafana_autoscaling_cpu_target
    scale_in_cooldown  = 300 # seconds
    scale_out_cooldown = 300 # seconds
  }
}

# Renderer Autoscaling Target
resource "aws_applicationautoscaling_target" "renderer" {
  service_namespace  = "ecs"
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${aws_ecs_service.renderer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.renderer_autoscaling_min
  max_capacity       = var.renderer_autoscaling_max
}

# Renderer Autoscaling Policy (CPU)
resource "aws_applicationautoscaling_policy" "renderer_cpu" {
  name               = "renderer-cpu-autoscaling"
  service_namespace  = "ecs"
  resource_id        = aws_applicationautoscaling_target.renderer.resource_id
  scalable_dimension = aws_applicationautoscaling_target.renderer.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.renderer_autoscaling_cpu_target
    scale_in_cooldown  = 300 # seconds
    scale_out_cooldown = 300 # seconds
  }
}

# Redis Autoscaling Target
resource "aws_applicationautoscaling_target" "redis" {
  service_namespace  = "ecs"
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${aws_ecs_service.redis.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.redis_autoscaling_min
  max_capacity       = var.redis_autoscaling_max
}

# Redis Autoscaling Policy (CPU)
resource "aws_applicationautoscaling_policy" "redis_cpu" {
  name               = "redis-cpu-autoscaling"
  service_namespace  = "ecs"
  resource_id        = aws_applicationautoscaling_target.redis.resource_id
  scalable_dimension = aws_applicationautoscaling_target.redis.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.redis_autoscaling_cpu_target
    scale_in_cooldown  = 300 # seconds
    scale_out_cooldown = 300 # seconds
  }
}