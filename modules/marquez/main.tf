locals {
  log_prefix = "/ecs/marquez"
}

##############################
# Data Sources
##############################
data "aws_lb" "public_alb" {
  name = var.alb_name
}

data "aws_lb_listener" "public_listener" {
  load_balancer_arn = data.aws_lb.public_alb.arn
  port              = 80
}

data "aws_lb" "internal_nlb" {
  name = var.nlb_name
}

##############################
# Target Groups
##############################
resource "aws_lb_target_group" "marquez_api_tg" {
  name        = "marquez-api-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/health"
    protocol = "HTTP"
    matcher  = "200-399"
  }
}

resource "aws_lb_target_group" "marquez_web_tg" {
  name        = "marquez-web-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200-399"
  }
}

resource "aws_lb_target_group" "marquez_db_tg" {
  name        = "marquez-db-tg"
  port        = 5432
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

##############################
# Listener Rules (Path-based)
##############################
resource "aws_lb_listener_rule" "marquez_api_rule" {
  listener_arn = data.aws_lb_listener.public_listener.arn
  priority     = 210

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.marquez_api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/marquez/api", "/marquez/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "marquez_web_rule" {
  listener_arn = data.aws_lb_listener.public_listener.arn
  priority     = 220

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.marquez_web_tg.arn
  }

  condition {
    path_pattern {
      values = ["/marquez", "/marquez/*"]
    }
  }
}

##############################
# Task Definitions
##############################
resource "aws_ecs_task_definition" "marquez_api" {
  family                   = "marquez-api-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name  = "marquez-api"
    image = "marquezproject/marquez:0.47.0"
    portMappings = [
      { containerPort = 5000 },
      { containerPort = 5001 }
    ]
    environment = [
      { name = "POSTGRES_HOST", value = "marquez-db.internal" },
      { name = "POSTGRES_USER", value = "marquez" },
      { name = "POSTGRES_PASSWORD", value = "marquez" },
      { name = "POSTGRES_DB", value = "marquez" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "${local.log_prefix}-api"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "api"
        awslogs-create-group  = "true"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "marquez_web" {
  family                   = "marquez-web-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name  = "marquez-web"
    image = "marquezproject/marquez-web:0.47.0"
    portMappings = [{ containerPort = 3000 }]
    environment = [
      { name = "MARQUEZ_HOST", value = "localhost" },
      { name = "MARQUEZ_PORT", value = "5000" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "${local.log_prefix}-web"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "web"
        awslogs-create-group  = "true"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "marquez_db" {
  family                   = "marquez-db-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name  = "marquez-db"
    image = "postgres:14"
    portMappings = [{ containerPort = 5432 }]
    environment = [
      { name = "POSTGRES_USER", value = "marquez" },
      { name = "POSTGRES_PASSWORD", value = "marquez" },
      { name = "POSTGRES_DB", value = "marquez" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "${local.log_prefix}-db"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "db"
        awslogs-create-group  = "true"
      }
    }
  }])
}

##############################
# ECS Services
##############################
resource "aws_ecs_service" "marquez_api" {
  name                   = "marquez-api"
  cluster                = var.ecs_cluster_id
  launch_type            = "FARGATE"
  desired_count          = var.marquez_api_desired_count
  task_definition        = aws_ecs_task_definition.marquez_api.arn
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.marquez_api_tg.arn
    container_name   = "marquez-api"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener_rule.marquez_api_rule]
}

resource "aws_ecs_service" "marquez_web" {
  name                   = "marquez-web"
  cluster                = var.ecs_cluster_id
  launch_type            = "FARGATE"
  desired_count          = var.marquez_web_desired_count
  task_definition        = aws_ecs_task_definition.marquez_web.arn
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.marquez_web_tg.arn
    container_name   = "marquez-web"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener_rule.marquez_web_rule]
}

resource "aws_ecs_service" "marquez_db" {
  name                   = "marquez-db"
  cluster                = var.ecs_cluster_id
  launch_type            = "FARGATE"
  desired_count          = 1
  task_definition        = aws_ecs_task_definition.marquez_db.arn
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.marquez_db_tg.arn
    container_name   = "marquez-db"
    container_port   = 5432
  }
}

##############################
# Application Auto Scaling: marquez-api
##############################
resource "aws_appautoscaling_target" "marquez_api" {
  max_capacity       = var.marquez_api_autoscaling_max
  min_capacity       = var.marquez_api_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/marquez-api"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "marquez_api_cpu" {
  name               = "marquez-api-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.marquez_api.resource_id
  scalable_dimension = aws_appautoscaling_target.marquez_api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.marquez_api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.marquez_api_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

##############################
# Application Auto Scaling: marquez-web
##############################
resource "aws_appautoscaling_target" "marquez_web" {
  max_capacity       = var.marquez_web_autoscaling_max
  min_capacity       = var.marquez_web_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/marquez-web"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "marquez_web_cpu" {
  name               = "marquez-web-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.marquez_web.resource_id
  scalable_dimension = aws_appautoscaling_target.marquez_web.scalable_dimension
  service_namespace  = aws_appautoscaling_target.marquez_web.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.marquez_web_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
