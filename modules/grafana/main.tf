############################################
# Load Balancers
############################################
resource "aws_lb" "public_alb" {
  name               = "grafana-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb" "internal_nlb" {
  name               = "grafana-internal-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids
}

############################################
# Target Groups
############################################
resource "aws_lb_target_group" "grafana_tg" {
  name        = "grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "renderer_tg" {
  name        = "renderer-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/render"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "redis_tg" {
  name        = "redis-tg"
  port        = 6379
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

############################################
# Listeners
############################################
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }
}

resource "aws_lb_listener_rule" "render_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.renderer_tg.arn
  }

  condition {
    path_pattern {
      values = ["/render*"]
    }
  }
}

############################################
# Secrets Manager
############################################
data "aws_secretsmanager_secret_version" "grafana_password" {
  secret_id = var.db_secret_arn
}

############################################
# ECS Task Definitions
############################################
resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "grafana"
      image = "grafana/grafana-enterprise:11.6.1"
      portMappings = [{ containerPort = 3000 }]
      environment = [
        { name = "GF_DATABASE_HOST", value = var.db_endpoint },
        { name = "GF_DATABASE_NAME", value = "grafana" },
        { name = "GF_DATABASE_USER", value = "rajesh" },
        { name = "GF_DATABASE_PASSWORD", value = data.aws_secretsmanager_secret_version.grafana_password.secret_string },
        { name = "REDIS_PATH", value = aws_lb.internal_nlb.dns_name },
        { name = "GF_RENDERING_SERVER_URL", value = "http://${aws_lb.public_alb.dns_name}/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://${aws_lb.public_alb.dns_name}/" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "GF_LOG_FILTERS", value = "rendering:debug" }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/grafana-service",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "grafana"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "renderer" {
  family                   = "renderer-task"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "renderer"
      image = "grafana/grafana-image-renderer:3.12.5"
      portMappings = [{ containerPort = 8081 }]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/renderer-service",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "renderer"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "redis" {
  family                   = "redis-task"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "redis"
      image = "redis:latest"
      portMappings = [{ containerPort = 6379 }]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/redis-service",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "redis"
        }
      }
    }
  ])
}

############################################
# ECS Services
############################################
resource "aws_ecs_service" "grafana" {
  name            = "grafana-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana_tg.arn
    container_name   = "grafana"
    container_port   = 3000
  }
}

resource "aws_ecs_service" "renderer" {
  name            = "renderer-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count   = var.renderer_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.renderer_tg.arn
    container_name   = "renderer"
    container_port   = 8081
  }
}

resource "aws_ecs_service" "redis" {
  name            = "redis-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = var.redis_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.redis_tg.arn
    container_name   = "redis"
    container_port   = 6379
  }
}

############################################
# Autoscaling (Grafana, Renderer, Redis)
############################################
resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.grafana_autoscaling_max
  min_capacity       = var.grafana_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/grafana-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana_cpu" {
  name               = "grafana-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.grafana_autoscaling_cpu_target
  }
}

resource "aws_appautoscaling_target" "renderer" {
  max_capacity       = var.renderer_autoscaling_max
  min_capacity       = var.renderer_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/renderer-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer_cpu" {
  name               = "renderer-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer.scalable_dimension
  service_namespace  = aws_appautoscaling_target.renderer.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.renderer_autoscaling_cpu_target
  }
}

resource "aws_appautoscaling_target" "redis" {
  max_capacity       = var.redis_autoscaling_max
  min_capacity       = var.redis_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/redis-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "redis_cpu" {
  name               = "redis-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis.resource_id
  scalable_dimension = aws_appautoscaling_target.redis.scalable_dimension
  service_namespace  = aws_appautoscaling_target.redis.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.redis_autoscaling_cpu_target
  }
}
