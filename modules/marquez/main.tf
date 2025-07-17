locals {
  log_prefix           = "/ecs/marquez/test"
  marquez_api_url_base = "http://${data.aws_lb.public_alb.dns_name}"
}

######################
# Load Balancers
######################
data "aws_lb" "public_alb" {
  name = var.alb_name
}

data "aws_lb" "internal_nlb" {
  name = var.nlb_name
}

######################
# default Listeners
######################
data "aws_lb_listener" "public_listener" {
  load_balancer_arn = data.aws_lb.public_alb.arn
  port              = 80
}



######################
# Target Groups
######################
resource "aws_lb_target_group" "api_tg" {
  name        = "marquez-api-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/api/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "web_tg" {
  name        = "marquez-web-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "db_tg" {
  name        = "marquez-db-tg"
  port        = 5432
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

######################
# Listener Rules
######################
resource "aws_lb_listener" "internal_tcp_5432" {
  load_balancer_arn = data.aws_lb.internal_nlb.arn
  port              = 5432
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.db_tg.arn
  }
}
resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = data.aws_lb_listener.public_listener.arn
  priority     = 1006

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api*", "/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "web_rule" {
  listener_arn = data.aws_lb_listener.public_listener.arn
  priority     = 1007

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

######################
# Log Groups
######################
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

######################
# Task Definitions
######################
resource "aws_ecs_task_definition" "api" {
  family                   = "d3po-marquez-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name  = "marquez-api"
    image = var.marquez_api_image
    portMappings = [
      { containerPort = 5000 },
      { containerPort = 5001 }
    ]
    environment = [
      { name = "MARQUEZ_POSTGRES_HOST", value = data.aws_lb.internal_nlb.dns_name },
      { name = "MARQUEZ_POSTGRES_PORT", value = var.marquez_postgres_port },
      { name = "MARQUEZ_POSTGRES_USER", value = var.marquez_postgres_user },
      { name = "MARQUEZ_POSTGRES_PASSWORD", value = var.marquez_postgres_password },
      { name = "MARQUEZ_POSTGRES_DB", value = var.marquez_postgres_db },
      { name = "MARQUEZ_CONFIG", value = "/usr/src/app/marquez.dev.yml" }
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
  family                   = "d3po-marquez-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "marquez-web"
    image       = "marquezproject/marquez-web:0.47.0"
    portMappings = [{ containerPort = 3000 }]
    environment = [
      { name = "MARQUEZ_HOST", value = local.marquez_api_url_base },
      { name = "MARQUEZ_PORT", value = "80" }
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
  family                   = "d3po-marquez-db"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "marquez-db"
    image       = "postgres:14"
    portMappings = [{ containerPort = 5432 }]
    environment = [
      { name = "POSTGRES_USER", value = var.marquez_postgres_user },
      { name = "POSTGRES_PASSWORD", value = var.marquez_postgres_password },
      { name = "POSTGRES_DB", value = var.marquez_postgres_db }
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

######################
# ECS Services
######################
resource "aws_ecs_service" "api" {
  name                   = "d3po-marquez-api"
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.api.arn
  desired_count          = var.marquez_api_desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
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

  health_check_grace_period_seconds = 60
}

resource "aws_ecs_service" "web" {
  name                   = "d3po-marquez-web"
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.web.arn
  desired_count          = var.marquez_web_desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_tg.arn
    container_name   = "marquez-web"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener_rule.web_rule,
    aws_cloudwatch_log_group.web_logs
  ]

  health_check_grace_period_seconds = 60
}

resource "aws_ecs_service" "db" {
  name                   = "d3po-marquez-db"
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.db.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.db_tg.arn
    container_name   = "marquez-db"
    container_port   = 5432
  }

  depends_on = [
    aws_lb_listener.internal_tcp_5432,
    aws_cloudwatch_log_group.db_logs
  ]

  health_check_grace_period_seconds = 60
}

######################
# Auto Scaling
######################
resource "aws_appautoscaling_target" "api" {
  max_capacity       = var.marquez_api_autoscaling_max
  min_capacity       = var.marquez_api_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/d3po-marquez-api"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on         = [aws_ecs_service.api]
}

resource "aws_appautoscaling_policy" "api_cpu" {
  name                = "api-cpu-scaling"
  policy_type         = "TargetTrackingScaling"
  resource_id         = aws_appautoscaling_target.api.resource_id
  scalable_dimension  = aws_appautoscaling_target.api.scalable_dimension
  service_namespace   = aws_appautoscaling_target.api.service_namespace

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
  resource_id        = "service/${var.ecs_cluster_name}/d3po-marquez-web"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on         = [aws_ecs_service.web]
}

resource "aws_appautoscaling_policy" "web_cpu" {
  name                = "web-cpu-scaling"
  policy_type         = "TargetTrackingScaling"
  resource_id         = aws_appautoscaling_target.web.resource_id
  scalable_dimension  = aws_appautoscaling_target.web.scalable_dimension
  service_namespace   = aws_appautoscaling_target.web.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.marquez_web_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
