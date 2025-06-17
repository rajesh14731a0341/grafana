# ---------------------------------------------
# VARIABLES AND LOCALS
# ---------------------------------------------

locals {
  api_image  = "marquezproject/marquez:0.47.0"
  web_image  = "marquezproject/marquez-web:0.47.0"
  db_image   = "postgres:14"

  db_username = "marquez"
  db_password = "marquez"
  db_name     = "marquez"
}

# ---------------------------------------------
# LOAD BALANCERS
# ---------------------------------------------

resource "aws_lb" "public_alb" {
  name               = "marquez-public-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.security_group_id]
}

resource "aws_lb" "internal_nlb" {
  name               = "marquez-internal-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids
  security_groups    = [var.security_group_id]
}

resource "aws_lb_listener" "alb_listener" {
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

resource "aws_lb_listener" "postgres_listener" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = 5432
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.postgres_tg.arn
  }
}

resource "aws_lb_target_group" "api_tg" {
  name        = "api-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/api/v1/namespaces"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name        = "web-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group" "postgres_tg" {
  name        = "postgres-tg"
  port        = 5432
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = "5432"
  }
}

resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "web_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 20

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

# ---------------------------------------------
# LOG GROUPS
# ---------------------------------------------

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/marquez-api"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/marquez-web"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "db" {
  name              = "/ecs/marquez-db"
  retention_in_days = 7
}

# ---------------------------------------------
# ECS TASK DEFINITIONS
# ---------------------------------------------

resource "aws_ecs_task_definition" "api" {
  family                   = "marquez-api"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "marquez-api",
      image     = local.api_image,
      essential = true,
      portMappings = [{ containerPort = 5000 }],
      environment = [
        {
          name  = "DATABASE_URL",
          value = "jdbc:postgresql://${aws_lb.internal_nlb.dns_name}:5432/${local.db_name}?user=${local.db_username}&password=${local.db_password}"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.api.name,
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "marquez-api"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "web" {
  family                   = "marquez-web"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "marquez-web",
      image     = local.web_image,
      essential = true,
      portMappings = [{ containerPort = 3000 }],
      environment = [
        { name = "MARQUEZ_HOST", value = "marquez-api" },
        { name = "MARQUEZ_PORT", value = "5000" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.web.name,
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "marquez-web"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "db" {
  family                   = "marquez-db"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "marquez-db",
      image     = local.db_image,
      essential = true,
      portMappings = [{ containerPort = 5432 }],
      environment = [
        { name = "POSTGRES_USER", value = local.db_username },
        { name = "POSTGRES_PASSWORD", value = local.db_password },
        { name = "POSTGRES_DB", value = local.db_name }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.db.name,
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "marquez-db"
        }
      }
    }
  ])
}

# ---------------------------------------------
# ECS SERVICES
# ---------------------------------------------

resource "aws_ecs_service" "api" {
  name            = "marquez-api"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.api.arn
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    assign_public_ip = false
    security_groups = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_tg.arn
    container_name   = "marquez-api"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.alb_listener]
}

resource "aws_ecs_service" "web" {
  name            = "marquez-web"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.web.arn
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    assign_public_ip = false
    security_groups = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_tg.arn
    container_name   = "marquez-web"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.alb_listener]
}

resource "aws_ecs_service" "db" {
  name            = "marquez-db"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.db.arn
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    assign_public_ip = false
    security_groups = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.postgres_tg.arn
    container_name   = "marquez-db"
    container_port   = 5432
  }

  depends_on = [aws_lb_listener.postgres_listener]
}

# ---------------------------------------------
# AUTO SCALING FOR ECS SERVICES
# ---------------------------------------------

resource "aws_appautoscaling_target" "api" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/marquez-api"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.api]
}

resource "aws_appautoscaling_policy" "api_cpu_policy" {
  name               = "marquez-api-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "web" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/marquez-web"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.web]
}

resource "aws_appautoscaling_policy" "web_cpu_policy" {
  name               = "marquez-web-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.web.resource_id
  scalable_dimension = aws_appautoscaling_target.web.scalable_dimension
  service_namespace  = aws_appautoscaling_target.web.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
