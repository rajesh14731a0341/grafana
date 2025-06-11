locals {
  log_group_prefix = "/ecs/marquez"

  services = {
    marquez-api = {
      image = "marquezproject/marquez:0.47.0"
      port  = 5000
      env = [
        { name = "JAVA_OPTS", value = "-Dlogback.configurationFile=/etc/marquez/logback.xml" },
        { name = "MARQUEZ_CONFIG", value = "/app/config.yml" },
        { name = "MARQUEZ_DB_HOST", value = "marquez-db.${var.cloudmap_namespace}" },
        { name = "MARQUEZ_DB_PORT", value = "5432" },
        { name = "MARQUEZ_DB_NAME", value = "marquez" },
        { name = "MARQUEZ_DB_USER", value = "marquez" },
        { name = "MARQUEZ_DB_PASSWORD", value = "marquez" }
      ]
      desired_count = var.marquez_api_desired_count
      min_capacity  = var.marquez_api_autoscaling_min
      max_capacity  = var.marquez_api_autoscaling_max
      cpu_target    = var.marquez_api_autoscaling_cpu_target
    }

    marquez-db = {
      image = "postgres:14"
      port  = 5432
      env = [
        { name = "POSTGRES_USER", value = "marquez" },
        { name = "POSTGRES_PASSWORD", value = "marquez" },
        { name = "POSTGRES_DB", value = "marquez" }
      ]
      desired_count = var.marquez_db_desired_count
      min_capacity  = var.marquez_db_autoscaling_min
      max_capacity  = var.marquez_db_autoscaling_max
      cpu_target    = var.marquez_db_autoscaling_cpu_target
    }

    marquez-web = {
      image = "marquezproject/marquez-web:0.47.0"
      port  = 3000
      env = [
        { name = "MARQUEZ_HOST", value = "marquez-api.${var.cloudmap_namespace}" },
        { name = "MARQUEZ_PORT", value = "5000" }
      ]
      desired_count = var.marquez_web_desired_count
      min_capacity  = var.marquez_web_autoscaling_min
      max_capacity  = var.marquez_web_autoscaling_max
      cpu_target    = var.marquez_web_autoscaling_cpu_target
    }
  }
}

resource "aws_ecs_task_definition" "task" {
  for_each                 = local.services
  family                   = each.key
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name         = each.key
    image        = each.value.image
    cpu          = 512
    memory       = 1024
    essential    = true
    portMappings = [{
      containerPort = each.value.port
      protocol      = "tcp"
    }]
    environment = each.value.env
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-region        = "us-east-1"
        awslogs-group         = "${local.log_group_prefix}-${each.key}"
        awslogs-stream-prefix = each.key
      }
    }
  }])
}

resource "aws_ecs_service" "service" {
  for_each               = local.services
  name                   = each.key
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.task[each.key].arn
  desired_count          = each.value.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.discovery[each.key].arn
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  for_each           = local.services
  max_capacity       = each.value.max_capacity
  min_capacity       = each.value.min_capacity
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${each.key}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_policy" {
  for_each = local.services

  name               = "${each.key}-cpu-policy"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  policy_type = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = each.value.cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_service_discovery_service" "discovery" {
  for_each = local.services

  name = each.key

  dns_config {
    namespace_id   = var.cloudmap_namespace_id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
