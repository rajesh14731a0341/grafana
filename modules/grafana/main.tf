locals {
  log_prefix = "/ecs/grafana"
}

##############################
# Data Sources for Load Balancers (ALB and NLB)
# These data blocks reference existing load balancers.
##############################
data "aws_lb" "public_alb" {
  name = var.alb_name
}

data "aws_lb" "internal_nlb" {
  name = var.nlb_name
}

##############################
# Data Sources for Existing Target Groups
# These data blocks simply reference your pre-existing target groups by their ARNs.
# Terraform will only read their configuration, not attempt to create or modify them.
##############################
data "aws_lb_target_group" "grafana_tg" {
  arn = var.grafana_tg_arn
}

data "aws_lb_target_group" "renderer_tg" {
  arn = var.renderer_tg_arn
}

data "aws_lb_target_group" "redis_tg" {
  arn = var.redis_tg_arn
}

##############################
# Data Sources for Existing Load Balancer Listeners
# These data blocks simply reference your pre-existing listeners by their ARNs.
# Terraform will only read their configuration, not attempt to create or modify them.
##############################
data "aws_lb_listener" "public_listener" {
  arn = var.grafana_listener_arn # This is your public ALB listener's ARN
}

data "aws_lb_listener" "redis_tcp" {
  arn = var.redis_tcp_listener_arn # This is your NLB Redis listener's ARN
}

##############################
# NEW: Data Sources for Existing Listener Rules
# These data blocks explicitly reference the pre-existing listener rules.
# Terraform will verify their existence before proceeding with ECS service creation.
##############################
data "aws_lb_listener_rule" "grafana_rule" {
  arn = var.grafana_listener_rule_arn
}

data "aws_lb_listener_rule" "renderer_rule" {
  arn = var.renderer_listener_rule_arn
}


##############################
# Secrets Manager (assuming you have access to read secrets)
##############################
data "aws_secretsmanager_secret_version" "db" {
  secret_id = var.db_secret_arn
}

##############################
# CloudWatch Log Groups (Explicitly Managed by Terraform for Grafana & Renderer)
# Redis log group is automatically created by ECS via awslogs-create-group = "true"
##############################
resource "aws_cloudwatch_log_group" "grafana_logs" {
  name              = "${local.log_prefix}-grafana"
  retention_in_days = 30 # Adjust retention as needed (e.g., 7, 30, 90, 365, etc.)
  tags = {
    Application = "Grafana"
    Environment = "Production" # Or appropriate environment tag
  }
}

resource "aws_cloudwatch_log_group" "renderer_logs" {
  name              = "${local.log_prefix}-renderer"
  retention_in_days = 30 # Adjust retention as needed
  tags = {
    Application = "Grafana Renderer"
    Environment = "Production" # Or appropriate environment tag
  }
}

resource "aws_cloudwatch_log_group" "redis_logs" {
  name              = "${local.log_prefix}-redis"
  retention_in_days = 30 # Adjust retention as needed
  tags = {
    Application = "Redis"
    Environment = "Production" # Or appropriate environment tag
  }
  # Although the ECS task definition uses awslogs-create-group = "true",
  # it's good practice to manage log groups explicitly with Terraform for consistency
  # and to control properties like retention and tags.
  # If this resource is present, ECS will use it rather than creating its own.
}


##############################
# ECS Task Definitions (these are managed by your Terraform config)
##############################
resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "grafana"
    image       = "grafana/grafana-enterprise:latest"
    portMappings = [{ containerPort = 3000 }]
    environment = [
      { name = "GF_SERVER_ROOT_URL",            value = "http://${var.grafana_domain_name}" },
      { name = "GF_SERVER_SERVE_FROM_SUB_PATH", value = "false" },
      { name = "GF_DATABASE_TYPE",              value = "postgres" },
      { name = "GF_DATABASE_HOST",              value = var.db_endpoint },
      { name = "GF_DATABASE_NAME",              value = "grafana" },
      { name = "GF_DATABASE_USER",              value = "rajesh" },
      { name = "GF_DATABASE_PASSWORD",          value = data.aws_secretsmanager_secret_version.db.secret_string },
      { name = "GF_DATABASE_SSL_MODE",          value = "require" },
      { name = "GF_RENDERING_SERVER_URL",       value = "http://${data.aws_lb.public_alb.dns_name}/render" },
      { name = "GF_RENDERING_CALLBACK_URL",     value = "http://${var.grafana_domain_name}" },
      { name = "REDIS_PATH",                    value = "${data.aws_lb.internal_nlb.dns_name}:6379" },
      { name = "REDIS_DB",                      value = "1" },
      { name = "REDIS_CACHETIME",               value = "12000" },
      { name = "CACHING",                       value = "Y" },
      { name = "GF_PLUGIN_ALLOW_LOCAL_MODE",    value = "true" },
      { name = "GF_LOG_FILTERS",                value = "rendering:debug" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.grafana_logs.name # Reference explicit resource
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "grafana"
        awslogs-create-group  = "true" # Keep this true for robustness, it won't create if group exists.
      }
    }
  }])
}

resource "aws_ecs_task_definition" "renderer" {
  family                   = "renderer-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "renderer"
    image       = "grafana/grafana-image-renderer:latest"
    portMappings = [{ containerPort = 8081 }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.renderer_logs.name # Reference explicit resource
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "renderer"
        awslogs-create-group  = "true" # Keep this true for robustness
      }
    }
  }])
}

resource "aws_ecs_task_definition" "redis" {
  family                   = "redis-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "redis"
    image       = "redis:latest"
    portMappings = [{ containerPort = 6379 }]
    command     = ["redis-server", "--bind", "0.0.0.0"]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.redis_logs.name # Reference explicit resource
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "redis"
        awslogs-create-group  = "true" # Keep this true for robustness
      }
    }
  }])
}

##############################
# ECS Services & Auto Scaling (these are managed by your Terraform config)
##############################
resource "aws_ecs_service" "grafana" {
  name                   = "grafana"
  cluster                = var.ecs_cluster_id
  launch_type            = "FARGATE"
  desired_count          = var.grafana_desired_count
  task_definition        = aws_ecs_task_definition.grafana.arn
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.grafana_tg.arn # Referencing the data source for Grafana TG
    container_name   = "grafana"
    container_port   = 3000
  }
  # Add explicit dependency on the listener rule and log group
  depends_on = [
    aws_cloudwatch_log_group.grafana_logs,
    data.aws_lb_listener_rule.grafana_rule
  ]
}

resource "aws_ecs_service" "renderer" {
  name                   = "renderer"
  cluster                = var.ecs_cluster_id
  launch_type            = "FARGATE"
  desired_count          = var.renderer_desired_count
  task_definition        = aws_ecs_task_definition.renderer.arn
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.renderer_tg.arn # Referencing the data source for Renderer TG
    container_name   = "renderer"
    container_port   = 8081
  }
  # Add explicit dependency on the listener rule and log group
  depends_on = [
    aws_cloudwatch_log_group.renderer_logs,
    data.aws_lb_listener_rule.renderer_rule
  ]
}

resource "aws_ecs_service" "redis" {
  name                   = "redis"
  cluster                = var.ecs_cluster_id
  launch_type            = "FARGATE"
  desired_count          = var.redis_desired_count
  task_definition        = aws_ecs_task_definition.redis.arn
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.redis_tg.arn # Referencing the data source for Redis TG
    container_name   = "redis"
    container_port   = 6379
  }
  # Add explicit dependency on the log group
  depends_on = [
    aws_cloudwatch_log_group.redis_logs
  ]
  # No depends_on on redis_tcp listener as NLB listeners don't have rules in the same way ALBs do for services.
}

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
    predefined_metric_specification { predefined_metric_type = "ECSServiceAverageCPUUtilization" }
    target_value                   = var.grafana_autoscaling_cpu_target
    scale_in_cooldown              = 60
    scale_out_cooldown             = 60
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
    predefined_metric_specification { predefined_metric_type = "ECSServiceAverageCPUUtilization" }
    target_value                   = var.renderer_autoscaling_cpu_target
    scale_in_cooldown              = 60
    scale_out_cooldown             = 60
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
    predefined_metric_specification { predefined_metric_type = "ECSServiceAverageCPUUtilization" }
    target_value                   = var.redis_autoscaling_cpu_target
    scale_in_cooldown              = 60
    scale_out_cooldown             = 60
  }
}