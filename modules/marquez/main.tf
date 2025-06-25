locals {
  log_prefix            = "/ecs/marquez"
  postgres_host         = data.aws_lb.internal_nlb.dns_name
  marquez_api_url_base  = "http://${data.aws_lb.public_alb.dns_name}/marquez/api"
}

####################
# Load Balancers
####################

data "aws_lb" "public_alb" {
  name = var.alb_name
}

data "aws_lb" "internal_nlb" {
  name = var.nlb_name
}

data "aws_lb_listener" "public_http" {
  load_balancer_arn = data.aws_lb.public_alb.arn
  port              = 80
}

####################
# Target Groups
####################

resource "aws_lb_target_group" "api_tg" {
  name        = "marquez-api-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/api/v1/namespaces"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "web_tg" {
  name        = "marquez-web-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "db_tg" {
  name        = "marquez-db-tg"
  port        = 5432
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    protocol            = "TCP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

####################
# Listener Rules
####################

resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = data.aws_lb_listener.public_http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/marquez/api/*", "/marquez/api"]
    }
  }
}

resource "aws_lb_listener_rule" "web_rule" {
  listener_arn = data.aws_lb_listener.public_http.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  condition {
    path_pattern {
      values = ["/marquez/web/*", "/marquez/web"]
    }
  }
}

resource "aws_lb_listener" "db_tcp" {
  load_balancer_arn = data.aws_lb.internal_nlb.arn
  port              = 5432
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.db_tg.arn
  }
}

####################
# Log Groups
####################

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "${local.log_prefix}/api"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "web_logs" {
  name              = "${local.log_prefix}/web"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "db_logs" {
  name              = "${local.log_prefix}/db"
  retention_in_days = 7
}

####################
# ECS Task Definitions
####################

resource "aws_ecs_task_definition" "api" {
  family                   = "marquez-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "marquez-api"
    image       = var.marquez_api_image
    portMappings = [{ containerPort = 5000 }]
    environment = [
      { name = "POSTGRES_HOST", value = local.postgres_host },
      { name = "POSTGRES_PORT", value = "5432" },
      { name = "POSTGRES_USER", value = "marquez" },
      { name = "POSTGRES_PASSWORD", value = "marquez" },
      { name = "POSTGRES_DB", value = "marquez" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.api_logs.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "web" {
  family                   = "marquez-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "marquez-web"
    image       = var.marquez_web_image
    portMappings = [{ containerPort = 8080 }]
    environment = [
      { name = "MARQUEZ_API_BASE", value = local.marquez_api_url_base }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.web_logs.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "db" {
  family                   = "marquez-db"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "marquez-db"
    image       = "postgres:13"
    portMappings = [{ containerPort = 5432 }]
    environment = [
      { name = "POSTGRES_USER", value = "marquez" },
      { name = "POSTGRES_PASSWORD", value = "marquez" },
      { name = "POSTGRES_DB", value = "marquez" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.db_logs.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

####################
# ECS Services
####################

resource "aws_ecs_service" "api" {
  name            = "marquez-api"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.marquez_api_desired_count
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_tg.arn
    container_name   = "marquez-api"
    container_port   = 5000
  }

  depends_on = [
    aws_lb_listener_rule.api_rule,
    aws_cloudwatch_log_group.api_logs
  ]
}

resource "aws_ecs_service" "web" {
  name            = "marquez-web"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = var.marquez_web_desired_count
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_tg.arn
    container_name   = "marquez-web"
    container_port   = 8080
  }

  depends_on = [
    aws_lb_listener_rule.web_rule,
    aws_cloudwatch_log_group.web_logs
  ]
}

resource "aws_ecs_service" "db" {
  name            = "marquez-db"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.db.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.db_tg.arn
    container_name   = "marquez-db"
    container_port   = 5432
  }

  depends_on = [
    aws_lb_listener.db_tcp,
    aws_cloudwatch_log_group.db_logs
  ]
}

####################
# Auto Scaling
####################

resource "aws_appautoscaling_target" "api" {
  max_capacity       = var.marquez_api_autoscaling_max
  min_capacity       = var.marquez_api_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "api_cpu" {
  name                    = "api-cpu-scaling"
  policy_type             = "TargetTrackingScaling"
  resource_id             = aws_appautoscaling_target.api.resource_id
  scalable_dimension      = aws_appautoscaling_target.api.scalable_dimension
  service_namespace       = aws_appautoscaling_target.api.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.marquez_api_autoscaling_cpu_target
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
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.web.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "web_cpu" {
  name                    = "web-cpu-scaling"
  policy_type             = "TargetTrackingScaling"
  resource_id             = aws_appautoscaling_target.web.resource_id
  scalable_dimension      = aws_appautoscaling_target.web.scalable_dimension
  service_namespace       = aws_appautoscaling_target.web.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.marquez_web_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}