locals {
  service_configs = {
    marquez-api = {
      image          = "marquezproject/marquez:0.47.0"
      container_port = 5000
      host_path      = "/api/*"
      cpu_target     = 70
    }
    marquez-db = {
      image          = "postgres:14"
      container_port = 5432
      cpu_target     = 70
    }
    marquez-web = {
      image          = "marquezproject/marquez-web:0.47.0"
      container_port = 3000
      host_path      = "/*"
      cpu_target     = 70
    }
  }
}

######################################
# Load Balancer
######################################

resource "aws_lb" "public_alb" {
  name               = "marquez-public-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.security_group_id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group" "tg" {
  for_each = {
    for k, v in local.service_configs :
    k => v if contains(["marquez-api", "marquez-web"], k)
  }

  name        = "${each.key}-tg"
  port        = each.value.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

resource "aws_lb_listener_rule" "listener_rules" {
  for_each = {
    for k, v in local.service_configs :
    k => v if contains(["marquez-api", "marquez-web"], k)
  }

  listener_arn = aws_lb_listener.http.arn
  priority     = each.key == "marquez-web" ? 10 : 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.host_path]
    }
  }
}

######################################
# CloudWatch Logs
######################################

resource "aws_cloudwatch_log_group" "logs" {
  for_each = local.service_configs
  name              = "/ecs/${each.key}"
  retention_in_days = 7
}

######################################
# Task Definitions
######################################

resource "aws_ecs_task_definition" "task" {
  for_each = local.service_configs

  family                   = each.key
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = each.value.image
      essential = true

      portMappings = [
        {
          containerPort = each.value.container_port
          hostPort      = each.value.container_port
          protocol      = "tcp"
        }
      ]

      environment = (
        each.key == "marquez-db" ? [
          { name = "POSTGRES_USER", value = "marquez" },
          { name = "POSTGRES_PASSWORD", value = "marquez" },
          { name = "POSTGRES_DB", value = "marquez" }
        ] :
        each.key == "marquez-api" ? [
          { name = "POSTGRES_USER", value = "marquez" },
          { name = "POSTGRES_PASSWORD", value = "marquez" },
          { name = "POSTGRES_DB", value = "marquez" },
          { name = "POSTGRES_HOST", value = "marquez-db" },
          { name = "POSTGRES_PORT", value = "5432" }
        ] :
        each.key == "marquez-web" ? [
          { name = "MARQUEZ_HOST", value = "marquez-api" },
          { name = "MARQUEZ_PORT", value = "5000" }
        ] : []
      )

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.logs[each.key].name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = each.key
        }
      }
    }
  ])
}

######################################
# ECS Services
######################################

resource "aws_ecs_service" "service" {
  for_each = local.service_configs

  name            = each.key
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = 1
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = [var.security_group_id]
  }

  task_definition = aws_ecs_task_definition.task[each.key].arn

  dynamic "load_balancer" {
    for_each = contains(["marquez-api", "marquez-web"], each.key) ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.tg[each.key].arn
      container_name   = each.key
      container_port   = each.value.container_port
    }
  }

  depends_on = [aws_lb_listener.http]
}

######################################
# Auto Scaling
######################################

resource "aws_appautoscaling_target" "ecs_target" {
  for_each = local.service_configs

  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/${each.key}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.service]
}

resource "aws_appautoscaling_policy" "cpu_policy" {
  for_each = local.service_configs

  name               = "${each.key}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = each.value.cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}
