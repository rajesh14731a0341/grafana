locals {
  db_endpoint = "grafana-rds.c030msui2s50.us-east-1.rds.amazonaws.com"
  db_name     = "grafana"
  db_user     = "rajesh"
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_secret_arn
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "grafana.local"
  description = "Service discovery for ECS services"
  vpc         = var.vpc_id
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/rajesh-grafana"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "rajesh-grafana"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:11.6.1"
      portMappings = [{ containerPort = 3000 }]
      environment = [
        { name = "GF_DATABASE_TYPE",             value = "postgres" },
        { name = "GF_DATABASE_HOST",             value = "${local.db_endpoint}:5432" },
        { name = "GF_DATABASE_NAME",             value = local.db_name },
        { name = "GF_DATABASE_USER",             value = local.db_user },
        { name = "GF_DATABASE_PASSWORD",         value = data.aws_secretsmanager_secret_version.db_password.secret_string },
        { name = "GF_DATABASE_SSL_MODE",         value = "require" },
        { name = "REDIS_PATH",                   value = "redis:6379" },
        { name = "REDIS_DB",                     value = "1" },
        { name = "REDIS_CACHETIME",              value = "12000" },
        { name = "CACHING",                      value = "Y" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE",   value = "true" },
        { name = "GF_RENDERING_SERVER_URL",      value = "http://renderer:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL",    value = "http://grafana:3000/" },
        { name = "GF_LOG_FILTERS",               value = "rendering:debug" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grafana.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "grafana" {
  name            = "rajesh-grafana-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.grafana.arn
  }
}

resource "aws_service_discovery_service" "grafana" {
  name = "grafana"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
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

resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.grafana_autoscaling_max
  min_capacity       = var.grafana_autoscaling_min
  resource_id        = "service/${split("/", aws_ecs_service.grafana.id)[1]}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana" {
  name               = "cpu-autoscaling-grafana"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana.scalable_dimension

  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.grafana_autoscaling_cpu_target
    scale_in_cooldown  = 30
    scale_out_cooldown = 30
  }
}
