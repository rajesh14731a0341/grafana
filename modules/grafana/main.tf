locals {
  services = {
    grafana = {
      image          = "grafana/grafana-enterprise:11.6.1"
      container_name = "grafana"
      cpu            = 512
      memory         = 1024
      desired_count  = var.grafana_desired_count
      min_capacity   = var.grafana_min_capacity
      max_capacity   = var.grafana_max_capacity
      target_cpu_utilization = 70
      port_mappings = [{
        container_port = 3000
        host_port      = 3000
        protocol       = "tcp"
      }]
      environment = {
        "GF_SECURITY_ADMIN_PASSWORD"      = "admin"
        "GF_DATABASE_TYPE"                 = "postgres"
        "GF_DATABASE_HOST"                 = "database-1.c030msui2s50.us-east-1.rds.amazonaws.com"
        "GF_DATABASE_NAME"                 = "grafana"
        "GF_DATABASE_USER"                 = "postgres"
        "GF_DATABASE_SSL_MODE"             = "disable"
        "GF_DATABASE_PASSWORD_SECRET_ARN" = var.postgres_secret_arn
        "GF_RENDERING_SERVER_URL"          = "http://renderer:8081/render"
        "GF_RENDERING_CALLBACK_URL"        = "http://grafana:3000/"
        "REDIS_HOST"                      = "redis"
        "REDIS_PORT"                      = "6379"
        "REDIS_DB"                        = "1"
        "REDIS_CACHETIME"                 = "12000"
        "CACHING"                        = "Y"
        "GF_PLUGIN_ALLOW_LOCAL_MODE"      = "true"
        "GF_LOG_FILTERS"                  = "rendering:debug"
      }
    }
    renderer = {
      image          = "grafana/grafana-image-renderer:3.12.5"
      container_name = "renderer"
      cpu            = 256
      memory         = 512
      desired_count  = var.renderer_desired_count
      min_capacity   = var.renderer_min_capacity
      max_capacity   = var.renderer_max_capacity
      target_cpu_utilization = 60
      port_mappings = [{
        container_port = 8081
        host_port      = 8081
        protocol       = "tcp"
      }]
      environment = {}
    }
    redis = {
      image          = "redis:latest"
      container_name = "redis"
      cpu            = 256
      memory         = 512
      desired_count  = var.redis_desired_count
      min_capacity   = var.redis_min_capacity
      max_capacity   = var.redis_max_capacity
      target_cpu_utilization = 60
      port_mappings = [{
        container_port = 6379
        host_port      = 6379
        protocol       = "tcp"
      }]
      environment = {}
    }
  }
}

resource "aws_ecs_task_definition" "tasks" {
  for_each = local.services

  family                   = each.value.container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(each.value.cpu)
  memory                   = tostring(each.value.memory)
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = each.value.container_name
    image     = each.value.image
    cpu       = each.value.cpu
    memory    = each.value.memory
    essential = true

    portMappings = each.value.port_mappings

    environment = [
      for k, v in each.value.environment : {
        name  = k
        value = v
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${each.value.container_name}"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = each.value.container_name
      }
    }
  }])
}

resource "aws_ecs_service" "services" {
  for_each            = local.services
  name                = "${each.value.container_name}-service"
  cluster             = var.cluster_arn
  task_definition     = aws_ecs_task_definition.tasks[each.key].arn
  desired_count       = each.value.desired_count
  launch_type         = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.tasks]
}

resource "aws_appautoscaling_target" "service_target" {
  for_each = local.services

  max_capacity       = each.value.max_capacity
  min_capacity       = each.value.min_capacity
  resource_id        = "service/${replace(var.cluster_arn, "arn:aws:ecs:us-east-1:736747734611:cluster/", "")}/${each.value.container_name}-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_policy" {
  for_each = local.services

  name               = "${each.value.container_name}-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.service_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.service_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = each.value.target_cpu_utilization
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
