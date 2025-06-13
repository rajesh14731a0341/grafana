locals {
  log_group_prefix = "/ecs/grafana"
  postgres_user    = "rajesh"
  postgres_db      = "grafana"
}

##########################
# CloudWatch Log Groups
##########################

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "${local.log_group_prefix}-grafana"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "renderer" {
  name              = "${local.log_group_prefix}-renderer"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "redis" {
  name              = "${local.log_group_prefix}-redis"
  retention_in_days = 7
}

##############################
# GRAFANA Task Definition
##############################

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:latest"
      essential = true
      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]
      environment = [
        { name = "GF_DATABASE_TYPE", value = "postgres" },
        { name = "GF_DATABASE_HOST", value = var.db_endpoint },
        { name = "GF_DATABASE_NAME", value = local.postgres_db },
        { name = "GF_DATABASE_USER", value = local.postgres_user },
        { name = "GF_DATABASE_SSL_MODE", value = "require" },
        { name = "GF_RENDERING_SERVER_URL", value = "http://${aws_lb.renderer_alb.dns_name}/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://${aws_lb.grafana_alb.dns_name}" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "GF_LOG_FILTERS", value = "rendering:debug" },
        { name = "REDIS_HOST", value = aws_lb.redis_nlb.dns_name },
        { name = "REDIS_PORT", value = "6379" }
      ]
      secrets = [{
        name      = "GF_DATABASE_PASSWORD"
        valueFrom = var.db_secret_arn
      }]
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

##############################
# GRAFANA Load Balancer (Public)
##############################

resource "aws_lb" "grafana_alb" {
  name               = "grafana-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [var.security_group_id]
}

resource "aws_lb_target_group" "grafana_tg" {
  name        = "grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "grafana_listener" {
  load_balancer_arn = aws_lb.grafana_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
    security_groups  = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana_tg.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  enable_execute_command = true

  depends_on = [aws_lb_listener.grafana_listener]
}

resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.grafana_autoscaling_max
  min_capacity       = var.grafana_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana_cpu" {
  name               = "grafana-cpu-scaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.grafana_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

##############################
# RENDERER Task + ALB (Internal)
##############################

resource "aws_lb" "renderer_alb" {
  name               = "renderer-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [var.security_group_id]
}

resource "aws_lb_target_group" "renderer_tg" {
  name     = "renderer-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "renderer_listener" {
  load_balancer_arn = aws_lb.renderer_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.renderer_tg.arn
  }
}

resource "aws_ecs_task_definition" "renderer" {
  family                   = "renderer-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:latest"
      essential = true
      portMappings = [{
        containerPort = 8080
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.renderer.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "renderer"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "renderer" {
  name            = "renderer"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count   = var.renderer_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = false
    security_groups  = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.renderer_tg.arn
    container_name   = "renderer"
    container_port   = 8080
  }

  enable_execute_command = true

  depends_on = [aws_lb_listener.renderer_listener]
}

resource "aws_appautoscaling_target" "renderer" {
  max_capacity       = var.renderer_autoscaling_max
  min_capacity       = var.renderer_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.renderer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer_cpu" {
  name               = "renderer-cpu-scaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.renderer.resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.renderer_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

##############################
# REDIS Task + NLB (Internal)
##############################

resource "aws_lb" "redis_nlb" {
  name               = "redis-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "redis_tg" {
  name     = "redis-tg"
  port     = 6379
  protocol = "TCP"
  vpc_id   = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "redis_listener" {
  load_balancer_arn = aws_lb.redis_nlb.arn
  port              = 6379
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis_tg.arn
  }
}

resource "aws_ecs_task_definition" "redis" {
  family                   = "redis-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "redis"
      image     = "redis:latest"
      essential = true
      portMappings = [{
        containerPort = 6379
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.redis.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "redis"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "redis" {
  name            = "redis"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = var.redis_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = false
    security_groups  = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.redis_tg.arn
    container_name   = "redis"
    container_port   = 6379
  }

  enable_execute_command = true

  depends_on = [aws_lb_listener.redis_listener]
}

resource "aws_appautoscaling_target" "redis" {
  max_capacity       = var.redis_autoscaling_max
  min_capacity       = var.redis_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.redis.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "redis_cpu" {
  name               = "redis-cpu-scaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.redis.resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.redis_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
