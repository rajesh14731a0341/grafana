# ---------------------------------------------
# Reference Existing ALB
# ---------------------------------------------
data "aws_lb" "existing_alb" {
  name = var.alb_name
}

data "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.existing_alb.arn
  port              = 80
}

# ---------------------------------------------
# Target Group & Listener Rule for Grafana
# ---------------------------------------------
resource "aws_lb_target_group" "grafana_cloudmap" {
  name        = "tg-grafana-cloudmap"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/grafana/login"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "grafana_cloudmap" {
  listener_arn = data.aws_lb_listener.http.arn
  priority     = 101
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_cloudmap.arn
  }
  condition {
    path_pattern {
      values = ["/grafana", "/grafana/*"]
    }
  }
}

# ---------------------------------------------
# Task Definitions
# ---------------------------------------------
resource "aws_ecs_task_definition" "grafana_cloudmap" {
  family                   = "grafana-cloudmap-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana-cloudmap"
      image     = "grafana/grafana-enterprise:11.6.1"
      portMappings = [{ containerPort = 3000 }]
      environment = [
        { name = "REDIS_PATH", value = "redis-cloudmap:6379" },
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" },
        { name = "CACHING", value = "Y" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "GF_RENDERING_SERVER_URL", value = "http://renderer-cloudmap:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana-cloudmap:3000/" },
        { name = "GF_LOG_FILTERS", value = "rendering: debug" },
        { name = "GF_DATABASE_HOST", value = var.db_endpoint },
        { name = "GF_DATABASE_NAME", value = var.db_name },
        { name = "GF_DATABASE_USER", value = var.db_username },
        { name = "GF_DATABASE_PASSWORD", valueFrom = var.db_secret_arn },
        { name = "GF_DATABASE_SSL_MODE", value = "require" }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/grafana-cloudmap"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana-cloudmap"
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "renderer_cloudmap" {
  family                   = "renderer-cloudmap-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "renderer-cloudmap"
      image     = "grafana/grafana-image-renderer:3.12.5"
      portMappings = [{ containerPort = 8081 }]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/renderer-cloudmap"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "renderer-cloudmap"
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "redis_cloudmap" {
  family                   = "redis-cloudmap-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "redis-cloudmap"
      image     = "redis:latest"
      portMappings = [{ containerPort = 6379 }]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/redis-cloudmap"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "redis-cloudmap"
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}

# ---------------------------------------------
# ECS Services with Cloud Map
# ---------------------------------------------
resource "aws_service_discovery_service" "grafana_cloudmap" {
  name = "grafana-cloudmap"
  dns_config {
    namespace_id = var.cloudmap_namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "renderer_cloudmap" {
  name = "renderer-cloudmap"
  dns_config {
    namespace_id = var.cloudmap_namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "redis_cloudmap" {
  name = "redis-cloudmap"
  dns_config {
    namespace_id = var.cloudmap_namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_ecs_service" "grafana_cloudmap" {
  name            = "rajesh-grafana-cloudmap-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana_cloudmap.arn
  launch_type     = "FARGATE"
  desired_count   = var.grafana_desired_count
  enable_execute_command = true
  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.grafana_cloudmap.arn
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.grafana_cloudmap.arn
    container_name   = "grafana-cloudmap"
    container_port   = 3000
  }
  depends_on = [aws_lb_listener_rule.grafana_cloudmap]
}

resource "aws_ecs_service" "renderer_cloudmap" {
  name            = "rajesh-renderer-cloudmap-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer_cloudmap.arn
  launch_type     = "FARGATE"
  desired_count   = var.renderer_desired_count
  enable_execute_command = true
  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.renderer_cloudmap.arn
  }
}

resource "aws_ecs_service" "redis_cloudmap" {
  name            = "rajesh-redis-cloudmap-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis_cloudmap.arn
  launch_type     = "FARGATE"
  desired_count   = var.redis_desired_count
  enable_execute_command = true
  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.redis_cloudmap.arn
  }
}

# ---------------------------------------------
# Auto Scaling Policies
# ---------------------------------------------
resource "aws_appautoscaling_target" "grafana_cloudmap" {
  max_capacity       = var.grafana_autoscaling_max
  min_capacity       = var.grafana_autoscaling_min
  resource_id        = "service/${replace(var.ecs_cluster_id, "arn:aws:ecs:us-east-1:[^:]+:cluster/", "")}/${aws_ecs_service.grafana_cloudmap.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana_cloudmap" {
  name               = "cpu-autoscaling-grafana-cloudmap"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana_cloudmap.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana_cloudmap.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana_cloudmap.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.grafana_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "renderer_cloudmap" {
  max_capacity       = var.renderer_autoscaling_max
  min_capacity       = var.renderer_autoscaling_min
  resource_id        = "service/${replace(var.ecs_cluster_id, "arn:aws:ecs:us-east-1:[^:]+:cluster/", "")}/${aws_ecs_service.renderer_cloudmap.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer_cloudmap" {
  name               = "cpu-autoscaling-renderer-cloudmap"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer_cloudmap.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer_cloudmap.scalable_dimension
  service_namespace  = aws_appautoscaling_target.renderer_cloudmap.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.renderer_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "redis_cloudmap" {
  max_capacity       = var.redis_autoscaling_max
  min_capacity       = var.redis_autoscaling_min
  resource_id        = "service/${replace(var.ecs_cluster_id, "arn:aws:ecs:us-east-1:[^:]+:cluster/", "")}/${aws_ecs_service.redis_cloudmap.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "redis_cloudmap" {
  name               = "cpu-autoscaling-redis-cloudmap"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis_cloudmap.resource_id
  scalable_dimension = aws_appautoscaling_target.redis_cloudmap.scalable_dimension
  service_namespace  = aws_appautoscaling_target.redis_cloudmap.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.redis_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
