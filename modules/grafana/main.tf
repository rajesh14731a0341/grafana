# CloudWatch Log Groups for each service
resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "renderer" {
  name              = "/ecs/grafana-renderer"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/grafana-redis"
  retention_in_days = var.log_retention_in_days
}

# ECS Task Definition for Grafana
resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.grafana_cpu
  memory                   = var.grafana_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:${var.grafana_image_version}"
      cpu       = var.grafana_cpu
      memory    = var.grafana_memory
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "GF_DATABASE_TYPE", value = "postgres" },
        { name = "GF_DATABASE_HOST", value = "${var.rds_endpoint}:${var.rds_port}" },
        { name = "GF_DATABASE_NAME", value = var.rds_database_name },
        { name = "GF_DATABASE_USER", value = var.rds_username },
        { name = "REDIS_PATH", value = "${aws_service_discovery_service.redis.name}:6379" }, # Using service discovery name
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" },
        { name = "CACHING", value = "Y" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "GF_RENDERING_SERVER_URL", value = "http://${aws_service_discovery_service.renderer.name}:8081/render" }, # Using service discovery name
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana:3000/" },
        { name = "GF_LOG_FILTERS", value = "rendering:debug" }
      ]
      secrets = [
        {
          name      = "GF_DATABASE_PASSWORD"
          valueFrom = var.rds_secret_arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "grafana"
        }
      }
    }
  ])
}

# ECS Task Definition for Grafana Image Renderer
resource "aws_ecs_task_definition" "renderer" {
  family                   = "grafana-renderer-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.renderer_cpu
  memory                   = var.renderer_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:${var.renderer_image_version}"
      cpu       = var.renderer_cpu
      memory    = var.renderer_memory
      essential = true
      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.renderer.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "renderer"
        }
      }
    }
  ])
}

# ECS Task Definition for Redis
resource "aws_ecs_task_definition" "redis" {
  family                   = "grafana-redis-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.redis_cpu
  memory                   = var.redis_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "redis"
      image     = "redis:latest"
      cpu       = var.redis_cpu
      memory    = var.redis_memory
      essential = true
      portMappings = [
        {
          containerPort = 6379
          hostPort      = 6379
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.redis.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "redis"
        }
      }
    }
  ])
}

# Service Discovery Private DNS Namespace
resource "aws_service_discovery_private_dns_namespace" "grafana" {
  name        = "grafana.local"
  description = "Private DNS namespace for Grafana services"
  # Extract VPC ID from cluster ARN (assuming cluster is in one VPC)
  vpc         = split("/", var.ecs_cluster_id)[4]
}

# Service Discovery Service for Grafana
resource "aws_service_discovery_service" "grafana" {
  name = "grafana"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.grafana.id
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

# Service Discovery Service for Renderer
resource "aws_service_discovery_service" "renderer" {
  name = "renderer"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.grafana.id
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

# Service Discovery Service for Redis
resource "aws_service_discovery_service" "redis" {
  name = "redis"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.grafana.id
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

# ECS Service for Grafana
resource "aws_ecs_service" "grafana" {
  name            = "rajesh-grafana-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_min_capacity # Set initial desired count to min capacity
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.grafana.arn
    port           = 3000
    container_name = "grafana"
  }

  # Allow autoscaling to manage desired_count
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Auto Scaling Target for Grafana
resource "aws_appautoscaling_target" "grafana_target" {
  max_capacity       = var.grafana_max_capacity
  min_capacity       = var.grafana_min_capacity
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy for Grafana (CPU Utilization)
resource "aws_appautoscaling_policy" "grafana_cpu_scaling" {
  name               = "grafana-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana_target.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.grafana_cpu_target_utilization
  }
}

# ECS Service for Grafana Image Renderer
resource "aws_ecs_service" "renderer" {
  name            = "rajesh-renderer-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count   = var.renderer_min_capacity # Set initial desired count to min capacity
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.renderer.arn
    port           = 8081
    container_name = "renderer"
  }

  # Allow autoscaling to manage desired_count
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Auto Scaling Target for Renderer
resource "aws_appautoscaling_target" "renderer_target" {
  max_capacity       = var.renderer_max_capacity
  min_capacity       = var.renderer_min_capacity
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${aws_ecs_service.renderer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy for Renderer (CPU Utilization)
resource "aws_appautoscaling_policy" "renderer_cpu_scaling" {
  name               = "renderer-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer_target.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.renderer_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.renderer_cpu_target_utilization
  }
}

# ECS Service for Redis
resource "aws_ecs_service" "redis" {
  name            = "rajesh-redis-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = var.redis_min_capacity # Set initial desired count to min capacity
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.redis.arn
    port           = 6379
    container_name = "redis"
  }

  # Allow autoscaling to manage desired_count
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Auto Scaling Target for Redis
resource "aws_appautoscaling_target" "redis_target" {
  max_capacity       = var.redis_max_capacity
  min_capacity       = var.redis_min_capacity
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${aws_ecs_service.redis.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy for Redis (CPU Utilization)
resource "aws_appautoscaling_policy" "redis_cpu_scaling" {
  name               = "redis-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis_target.resource_id
  scalable_dimension = aws_appautoscaling_target.redis_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.redis_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.redis_cpu_target_utilization
  }
}