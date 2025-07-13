locals {
  log_prefix = "/ecs/grafana"
}

##############################
# Data Sources for Load Balancers
##############################

data "aws_lb" "public_alb" {
  name = var.alb_name
}

data "aws_lb" "internal_nlb" {
  name = var.nlb_name
}

##############################
# Target Groups
##############################

resource "aws_lb_target_group" "grafana_tg" {
  name        = "grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/grafana/login"
    protocol = "HTTP"
    matcher  = "200-399"
  }
}


resource "aws_lb_target_group" "renderer_tg" {
  name        = "renderer-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/render/version"
    protocol            = "HTTP"
    matcher             = "200-499"
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

  health_check {
    protocol            = "TCP"
    port                = "traffic-port"  # ✅ This matches port 6379
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}


##############################
# Load Balancer Listeners
##############################
data "aws_lb_listener" "public_listener" {
  load_balancer_arn = data.aws_lb.public_alb.arn
  port              = 80
}





resource "aws_lb_listener_rule" "grafana_rule" {
  listener_arn = data.aws_lb_listener.public_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }

  condition {
    path_pattern {
      values = ["/grafana", "/grafana/*"]
    }
  }
}


resource "aws_lb_listener_rule" "renderer_rule" {
  listener_arn = data.aws_lb_listener.public_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.renderer_tg.arn
  }

  condition {
    path_pattern {
      values = ["/render", "/render/*"]
    }
  }
}


resource "aws_lb_listener" "redis_tcp" {
  load_balancer_arn = data.aws_lb.internal_nlb.arn
  port              = 6379
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis_tg.arn
  }
}

##############################
# Secrets Manager
##############################

data "aws_secretsmanager_secret_version" "db" {
  secret_id = var.db_secret_arn
}

##############################
# ECS Task Definitions
##############################

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "grafana"
      image = var.grafana_image
      portMappings = [{ containerPort = 3000 }]
      environment = [
        {
          name  = "GF_SERVER_ROOT_URL"
          value = "http://${data.aws_lb.public_alb.dns_name}/grafana"
        },
        {
          name  = "GF_SERVER_SERVE_FROM_SUB_PATH"
          value = "true"
        },
        { name = "GF_DATABASE_TYPE", value = "postgres" },
        { name = "GF_DATABASE_HOST", value = var.db_endpoint },
        { name = "GF_DATABASE_NAME", value = "grafana" },
        { name = "GF_DATABASE_USER", value = "rajesh" },
        {
          name  = "GF_DATABASE_PASSWORD"
          value = data.aws_secretsmanager_secret_version.db.secret_string
        },
        { name = "GF_DATABASE_SSL_MODE", value = "require" },
        {
          name = "GF_RENDERING_SERVER_URL"
          value = "http://${data.aws_lb.public_alb.dns_name}/render"
        },
        {
          name = "GF_RENDERING_CALLBACK_URL"
          value = "http://${data.aws_lb.public_alb.dns_name}/grafana"
        },
        {
          name = "REDIS_PATH"
          value = "${data.aws_lb.internal_nlb.dns_name}:6379"
        },
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" },
        { name = "CACHING", value = "Y" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "GF_LOG_FILTERS", value = "rendering:debug" }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.log_prefix}-grafana"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana"
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}



resource "aws_ecs_task_definition" "renderer" {
  family                   = "renderer-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "renderer"
      image = "grafana/grafana-image-renderer:latest"
      portMappings = [{ containerPort = 8081 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.log_prefix}-renderer"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "renderer"
          awslogs-create-group  = "true"
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

  container_definitions = jsonencode([{
    name  = "redis"
    image = "redis:latest"
    portMappings = [{
      containerPort = 6379
    }]
    command = ["redis-server", "--bind", "0.0.0.0"]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "${local.log_prefix}-redis"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "redis"
        awslogs-create-group  = "true"
      }
    }
  }])
}


##############################
# ECS Services
##############################

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = var.grafana_desired_count
  task_definition = aws_ecs_task_definition.grafana.arn

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

  enable_execute_command = true
  depends_on             = [aws_lb_listener_rule.grafana_rule]
}

resource "aws_ecs_service" "renderer" {
  name            = "renderer"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = var.renderer_desired_count
  task_definition = aws_ecs_task_definition.renderer.arn

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

  enable_execute_command = true
  depends_on             = [aws_lb_listener_rule.renderer_rule]
}

resource "aws_ecs_service" "redis" {
  name            = "redis"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = var.redis_desired_count
  task_definition = aws_ecs_task_definition.redis.arn

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

  enable_execute_command = true
  depends_on             = [aws_lb_listener.redis_tcp]
}

##############################
# Auto Scaling
##############################

resource "aws_appautoscaling_target" "grafana" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/grafana"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.grafana_autoscaling_min
  max_capacity       = var.grafana_autoscaling_max
  depends_on         = [aws_ecs_service.grafana]
}

resource "aws_appautoscaling_policy" "grafana_cpu" {
  name               = "grafana-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.grafana_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "renderer" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/renderer"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.renderer_autoscaling_min
  max_capacity       = var.renderer_autoscaling_max
  depends_on         = [aws_ecs_service.renderer]
}

resource "aws_appautoscaling_policy" "renderer_cpu" {
  name               = "renderer-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer.scalable_dimension
  service_namespace  = aws_appautoscaling_target.renderer.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.renderer_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "redis" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/redis"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.redis_autoscaling_min
  max_capacity       = var.redis_autoscaling_max
  depends_on         = [aws_ecs_service.redis]
}

resource "aws_appautoscaling_policy" "redis_cpu" {
  name               = "redis-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis.resource_id
  scalable_dimension = aws_appautoscaling_target.redis.scalable_dimension
  service_namespace  = aws_appautoscaling_target.redis.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.redis_autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

##################################
resource "local_file" "clickhouse_datasource_json" {
  for_each = var.clickhouse_sources

  content = templatefile("${path.module}/clickhouse-datasource.tpl.json", {
    name = each.key
    host = each.value.host
    port = each.value.port
  })

  filename = "${path.module}/clickhouse-${each.key}.json"
}

resource "null_resource" "clickhouse_provision" {
  for_each = var.clickhouse_sources

  provisioner "local-exec" {
    command = <<EOT
#!/bin/bash

# Wait for Grafana to be healthy
for i in {1..12}; do
  STATUS=$(curl -s -u ${var.grafana_admin_user}:${var.grafana_admin_password} http://${data.aws_lb.public_alb.dns_name}/grafana/api/health | grep '"database":"ok"')
  if [ ! -z "$STATUS" ]; then
    echo "Grafana is healthy."
    break
  fi
  echo "Waiting for Grafana..."
  sleep 10
done

# Create ClickHouse datasource
curl -s -u ${var.grafana_admin_user}:${var.grafana_admin_password} \
  -X POST http://${data.aws_lb.public_alb.dns_name}/grafana/api/datasources \
  -H "Content-Type: application/json" \
  -d @${local_file.clickhouse_datasource_json[each.key].filename}
EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    aws_ecs_service.grafana
  ]

  triggers = {
    datasource = local_file.clickhouse_datasource_json[each.key].content
  }
}
