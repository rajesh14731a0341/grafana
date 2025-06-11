locals {
  name_prefix = "marquez"
}

resource "aws_cloudwatch_log_group" "default" {
  for_each = toset(["api", "db", "web"])
  name     = "/ecs/${local.name_prefix}-${each.key}"
  retention_in_days = 7
}

##################
# Task Definitions
##################

resource "aws_ecs_task_definition" "marquez_api" {
  family                   = "${local.name_prefix}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions = jsonencode([
    {
      name      = "marquez-api"
      image     = "marquezproject/marquez:0.47.0"
      portMappings = [
        { containerPort = 5000 },
        { containerPort = 5001 }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.name_prefix}-api"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "marquez_db" {
  family                   = "${local.name_prefix}-db"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions = jsonencode([
    {
      name      = "marquez-db"
      image     = "postgres:14"
      portMappings = [{ containerPort = 5432 }]
      environment = [
        { name = "POSTGRES_USER", value = "marquez" },
        { name = "POSTGRES_PASSWORD", value = "marquez" },
        { name = "POSTGRES_DB", value = "marquez" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.name_prefix}-db"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "marquez_web" {
  family                   = "${local.name_prefix}-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions = jsonencode([
    {
      name      = "marquez-web"
      image     = "marquezproject/marquez-web:0.47.0"
      portMappings = [{ containerPort = 3000 }]
      environment = [
        { name = "MARQUEZ_HOST", value = "marquez-api.${var.cloudmap_namespace}" },
        { name = "MARQUEZ_PORT", value = "5000" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.name_prefix}-web"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

##################
# Services
##################

resource "aws_ecs_service" "marquez_api" {
  name            = "${local.name_prefix}-api"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.marquez_api.arn
  launch_type     = "FARGATE"
  desired_count   = var.marquez_api_desired_count
  enable_execute_command = true

  network_configuration {
    subnets         = var.subnet_ids
    assign_public_ip = true
    security_groups = [var.security_group_id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.marquez_api.arn
  }
}

resource "aws_ecs_service" "marquez_db" {
  name            = "${local.name_prefix}-db"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.marquez_db.arn
  launch_type     = "FARGATE"
  desired_count   = var.marquez_db_desired_count
  enable_execute_command = true

  network_configuration {
    subnets         = var.subnet_ids
    assign_public_ip = true
    security_groups = [var.security_group_id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.marquez_db.arn
  }
}

resource "aws_ecs_service" "marquez_web" {
  name            = "${local.name_prefix}-web"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.marquez_web.arn
  launch_type     = "FARGATE"
  desired_count   = var.marquez_web_desired_count
  enable_execute_command = true

  network_configuration {
    subnets         = var.subnet_ids
    assign_public_ip = true
    security_groups = [var.security_group_id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.marquez_web.arn
  }
}

##################
# Cloud Map Services
##################

resource "aws_service_discovery_service" "marquez_api" {
  name = "marquez-api"
  dns_config {
    namespace_id = var.cloudmap_namespace_id
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

resource "aws_service_discovery_service" "marquez_db" {
  name = "marquez-db"
  dns_config {
    namespace_id = var.cloudmap_namespace_id
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

resource "aws_service_discovery_service" "marquez_web" {
  name = "marquez-web"
  dns_config {
    namespace_id = var.cloudmap_namespace_id
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

##################
# Autoscaling
##################

resource "aws_appautoscaling_target" "api" {
  max_capacity       = var.marquez_api_autoscaling_max
  min_capacity       = var.marquez_api_autoscaling_min
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${aws_ecs_service.marquez_api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "api" {
  name               = "cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.marquez_api_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Repeat for DB and Web autoscaling

resource "aws_appautoscaling_target" "db" {
  max_capacity       = var.marquez_db_autoscaling_max
  min_capacity       = var.marquez_db_autoscaling_min
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${aws_ecs_service.marquez_db.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "db" {
  name               = "cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.db.resource_id
  scalable_dimension = aws_appautoscaling_target.db.scalable_dimension
  service_namespace  = aws_appautoscaling_target.db.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.marquez_db_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "web" {
  max_capacity       = var.marquez_web_autoscaling_max
  min_capacity       = var.marquez_web_autoscaling_min
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${aws_ecs_service.marquez_web.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "web" {
  name               = "cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.web.resource_id
  scalable_dimension = aws_appautoscaling_target.web.scalable_dimension
  service_namespace  = aws_appautoscaling_target.web.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.marquez_web_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
