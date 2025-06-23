##############################
# Locals (for ECS cluster name)
##############################
locals {
  ecs_cluster_name = element(split("/", var.ecs_cluster_id), length(split("/", var.ecs_cluster_id)) - 1)
}

###############################
# CloudWatch Log Groups
###############################
resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/redis-task"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "renderer" {
  name              = "/ecs/renderer-task"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana-task"
  retention_in_days = 7
}

###############################
# Renderer Auth Token Secret
###############################
resource "random_password" "renderer_auth_token_value" {
  length           = 32
  special          = true
  override_special = "!@#$%^&*-._~"
  min_special      = 4
  min_numeric      = 4
  min_upper        = 4
  min_lower        = 4
}

resource "aws_secretsmanager_secret" "grafana_renderer_token_secret" {
  name        = "grafana-renderer-auth-token-${var.environment}"
  description = "Authentication token for Grafana Image Renderer and Grafana."
}

resource "aws_secretsmanager_secret_version" "grafana_renderer_token_secret_version" {
  secret_id     = aws_secretsmanager_secret.grafana_renderer_token_secret.id
  secret_string = random_password.renderer_auth_token_value.result
}

###############################
# Redis ECS
###############################
resource "aws_ecs_task_definition" "redis" {
  family                   = "redis-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "redis"
    image       = "redis:latest"
    cpu         = 256
    memory      = 512
    essential   = true
    portMappings = [{
      containerPort = 6379
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.redis.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "redis"
      }
    }
  }])
}

resource "aws_service_discovery_service" "redis" {
  name         = "redis"
  namespace_id = var.cloudmap_namespace_id

  dns_config {
    namespace_id   = var.cloudmap_namespace_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 30
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "redis" {
  name            = "rajesh-2-redis-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = var.redis_desired_count
  launch_type     = "FARGATE"
  enable_execute_command = true
  force_new_deployment   = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.redis.arn
  }

  deployment_controller {
    type = "ECS"
  }
}

resource "aws_appautoscaling_target" "redis" {
  max_capacity       = var.redis_autoscaling_max
  min_capacity       = var.redis_autoscaling_min
  resource_id        = "service/${local.ecs_cluster_name}/${aws_ecs_service.redis.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "redis_cpu" {
  name               = "redis-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value         = var.redis_autoscaling_cpu_target
    scale_in_cooldown    = 60
    scale_out_cooldown   = 60
  }
}

###############################
# Renderer ECS
###############################
resource "aws_ecs_task_definition" "renderer" {
  family                   = "renderer-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "renderer"
    image       = "grafana/grafana-image-renderer:3.12.5"
    cpu         = 256
    memory      = 512
    essential   = true

    portMappings = [{
      containerPort = 8081
      protocol      = "tcp"
    }]

    # ✅ Now we run just the server — no shell wrapper, no CLI token
    command = ["node", "build/app.js", "server"]

    environment = [
      { name = "ENABLE_METRICS", value = "false" },
      { name = "LOG_LEVEL", value = "debug" }
    ]

    secrets = [
      {
        name      = "GF_RENDERING_SERVER_AUTH_TOKEN"
        valueFrom = aws_secretsmanager_secret.grafana_renderer_token_secret.arn
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.renderer.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "renderer"
      }
    }
  }])
}




resource "aws_service_discovery_service" "renderer" {
  name         = "renderer"
  namespace_id = var.cloudmap_namespace_id

  dns_config {
    namespace_id   = var.cloudmap_namespace_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 30
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "renderer" {
  name            = "rajesh-2-renderer-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count   = var.renderer_desired_count
  launch_type     = "FARGATE"
  enable_execute_command = true
  force_new_deployment   = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.renderer.arn
  }

  deployment_controller {
    type = "ECS"
  }
}

resource "aws_appautoscaling_target" "renderer" {
  max_capacity       = var.renderer_autoscaling_max
  min_capacity       = var.renderer_autoscaling_min
  resource_id        = "service/${local.ecs_cluster_name}/${aws_ecs_service.renderer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer_cpu" {
  name               = "renderer-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value         = var.renderer_autoscaling_cpu_target
    scale_in_cooldown    = 60
    scale_out_cooldown   = 60
  }
}

###############################
# Grafana ECS
###############################
data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = var.db_secret_arn
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "grafana"
    image       = "grafana/grafana-enterprise:11.6.1"
    cpu         = 512
    memory      = 1024
    essential   = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    environment = [
      { name = "GF_DATABASE_TYPE", value = "postgres" },
      { name = "GF_DATABASE_HOST", value = "grafana-rds.c030msui2s50.us-east-1.rds.amazonaws.com" },
      { name = "GF_DATABASE_NAME", value = "grafana" },
      { name = "GF_DATABASE_USER", value = "rajesh" },
      { name = "GF_DATABASE_SSL_MODE", value = "require" },
      { name = "GF_RENDERING_SERVER_URL", value = "http://renderer.${var.cloudmap_namespace}:8081/render" },
      { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana.${var.cloudmap_namespace}:3000/" },
      { name = "GF_RENDERING_EXTERNAL_ENABLED", value = "true" },
      { name = "GF_RENDERING_MODE", value = "remote" },
      { name = "GF_RENDERING_SERVER_HEADERS", value = "X-Grafana-Rendering-Token" }, # ✅ required for auth token to be sent
      { name = "REDIS_PATH", value = "redis.${var.cloudmap_namespace}:6379" },
      { name = "REDIS_DB", value = "1" },
      { name = "REDIS_CACHETIME", value = "12000" },
      { name = "CACHING", value = "Y" },
      { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
      { name = "GF_INSTALL_PLUGINS", value = "redis-datasource" },
      { name = "GF_AUTH_ANONYMOUS_ENABLED", value = "true" },
      { name = "GF_AUTH_ANONYMOUS_ORG_ROLE", value = "Viewer" },
      { name = "GF_LOG_LEVEL", value = "debug" }
    ]
    secrets = [
      {
        name      = "GF_DATABASE_PASSWORD"
        valueFrom = data.aws_secretsmanager_secret_version.db_secret.secret_id
      },
      {
        name      = "GF_RENDERING_SERVER_AUTH_TOKEN"
        valueFrom = aws_secretsmanager_secret.grafana_renderer_token_secret.arn
      },
      {
        name      = "GF_RENDERING_SERVER_ACCESS_TOKEN"
        valueFrom = aws_secretsmanager_secret.grafana_renderer_token_secret.arn
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.grafana.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "grafana"
      }
    }
  }])
}


resource "aws_service_discovery_service" "grafana" {
  name         = "grafana"
  namespace_id = var.cloudmap_namespace_id

  dns_config {
    namespace_id   = var.cloudmap_namespace_id
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

resource "aws_ecs_service" "grafana" {
  name            = "rajesh-2-grafana-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"
  enable_execute_command = true
  force_new_deployment   = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.grafana.arn
  }

  deployment_controller {
    type = "ECS"
  }
}

resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.grafana_autoscaling_max
  min_capacity       = var.grafana_autoscaling_min
  resource_id        = "service/${local.ecs_cluster_name}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana_cpu" {
  name               = "grafana-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value         = var.grafana_autoscaling_cpu_target
    scale_in_cooldown    = 60
    scale_out_cooldown   = 60
  }
}
