# Get PostgreSQL password from Secrets Manager
data "aws_secretsmanager_secret_version" "postgres_password" {
  secret_id = var.postgres_password_secret_arn
}

##############################
# CloudWatch Log Groups
##############################

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "renderer" {
  name              = "/ecs/renderer"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/redis"
  retention_in_days = 7
}

##############################
# ECS Task Definitions
##############################

# Grafana Task Definition
resource "aws_ecs_task_definition" "grafana" {
  family                   = "rajesh-grafana-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "grafana"
    image     = var.grafana_image
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "GF_DATABASE_TYPE"
        value = "postgres"
      },
      {
        name  = "GF_DATABASE_HOST"
        value = var.postgres_host
      },
      {
        name  = "GF_DATABASE_NAME"
        value = var.postgres_db
      },
      {
        name  = "GF_DATABASE_USER"
        value = var.postgres_user
      },
      {
        name  = "GF_DATABASE_PASSWORD"
        value = jsondecode(data.aws_secretsmanager_secret_version.postgres_password.secret_string)["password"]
      }
      # SSL settings can be uncommented in production as needed
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "grafana"
      }
    }
  }])
}

# Renderer Task Definition
resource "aws_ecs_task_definition" "renderer" {
  family                   = "rajesh-renderer-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "renderer"
    image     = var.renderer_image
    cpu       = 128
    memory    = 256
    essential = true
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.renderer.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "renderer"
      }
    }
  }])
}

# Redis Task Definition
resource "aws_ecs_task_definition" "redis" {
  family                   = "rajesh-redis-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "redis"
    image     = var.redis_image
    cpu       = 128
    memory    = 256
    essential = true
    portMappings = [{
      containerPort = 6379
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.redis.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "redis"
      }
    }
  }])
}

##############################
# ECS Services
##############################

# Grafana Service
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

  depends_on = [aws_ecs_task_definition.grafana]
}

# Renderer Service
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

  depends_on = [aws_ecs_task_definition.renderer]
}

# Redis Service
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

  depends_on = [aws_ecs_task_definition.redis]
}

##############################
# Autoscaling (Target Tracking) per Service
##############################

resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.grafana_max_capacity
  min_capacity       = var.grafana_min_capacity
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana" {
  name               = "grafana-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.grafana_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "renderer" {
  max_capacity       = var.renderer_max_capacity
  min_capacity       = var.renderer_min_capacity
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.renderer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer" {
  name               = "renderer-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer.scalable_dimension
  service_namespace  = aws_appautoscaling_target.renderer.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.renderer_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "redis" {
  max_capacity       = var.redis_max_capacity
  min_capacity       = var.redis_min_capacity
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.redis.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "redis" {
  name               = "redis-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis.resource_id
  scalable_dimension = aws_appautoscaling_target.redis.scalable_dimension
  service_namespace  = aws_appautoscaling_target.redis.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.redis_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
