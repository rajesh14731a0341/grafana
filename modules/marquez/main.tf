
locals {
  log_prefix           = "/ecs/marquez/test"
  marquez_api_url_base = "http://${data.aws_lb.public_alb.dns_name}"
}

######################
# Load Balancers (Data Sources - Always reference existing by name)
# These blocks retrieve information about existing ALBs and NLBs.
######################
data "aws_lb" "public_alb" {
  name = var.alb_name
}

data "aws_lb" "internal_nlb" {
  name = var.nlb_name
}

######################
# Target Groups (Data Sources - Reference existing by ARN)
# These blocks retrieve information about pre-existing target groups.
# Terraform will NOT create or modify these.
######################
data "aws_lb_target_group" "api_tg_prv_ip" {
  arn = var.marquez_api_tg_arn
}

data "aws_lb_target_group" "web_tg_prv_ip" {
  arn = var.marquez_web_tg_arn
}

data "aws_lb_target_group" "db_tg_prv_ip" {
  arn = var.marquez_db_tg_arn
}


######################
# Listeners (Data Sources - Reference existing by ARN)
# These blocks retrieve information about pre-existing listeners.
# Terraform will NOT create or modify these.
######################
data "aws_lb_listener" "public_http" {
  arn = var.marquez_http_listener_arn
}

data "aws_lb_listener" "internal_tcp_5432_prv_ip" {
  arn = var.marquez_tcp_listener_arn
}

######################
# Listener Rules (Data Sources - Reference existing by ARN)
# IMPORTANT: Since you do not have permissions to manage these,
# they are referenced as data sources. You MUST provide their ARNs
# in your .tfvars file. Terraform will NOT create or modify these rules.
######################
data "aws_lb_listener_rule" "api_rule_prv_ip" {
  arn = var.marquez_api_listener_rule_arn
}

data "aws_lb_listener_rule" "web_rule_prv_ip" {
  arn = var.marquez_web_listener_rule_arn
}


######################
# Log Groups (Resources - These are managed by your Terraform config)
# CloudWatch Log Groups are typically managed alongside services.
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
# Task Definitions (Resources - These are managed by your Terraform config)
# Task definitions define your container configurations.
######################
resource "aws_ecs_task_definition" "api" {
  family                   = "marquez-api-prv-ip"
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
      { name = "MARQUEZ_POSTGRES_PORT", value = "5432" },
      { name = "MARQUEZ_POSTGRES_USER", value = "marquez" },
      { name = "MARQUEZ_POSTGRES_PASSWORD", value = "marquez" },
      { name = "MARQUEZ_POSTGRES_DB", value = "marquez" },
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
  family                   = "marquez-web-prv-ip"
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
  family                   = "marquez-db-prv-ip"
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

######################
# ECS Services (Resources - These are managed by your Terraform config)
# These services deploy and manage your tasks.
######################
resource "aws_ecs_service" "api" {
  name                   = "marquez-api-prv-ip"
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
    target_group_arn = data.aws_lb_target_group.api_tg_prv_ip.arn
    container_name   = "marquez-api"
    container_port   = 5000
  }

  # Depend on the log group and the *existence* of the listener rule
  depends_on = [
    aws_cloudwatch_log_group.api_logs,
    data.aws_lb_listener_rule.api_rule_prv_ip # Now a data source
  ]

  health_check_grace_period_seconds = 60
}

resource "aws_ecs_service" "web" {
  name                   = "marquez-web-prv-ip"
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
    target_group_arn = data.aws_lb_target_group.web_tg_prv_ip.arn
    container_name   = "marquez-web"
    container_port   = 3000
  }

  # Depend on the log group and the *existence* of the listener rule
  depends_on = [
    aws_cloudwatch_log_group.web_logs,
    data.aws_lb_listener_rule.web_rule_prv_ip # Now a data source
  ]

  health_check_grace_period_seconds = 60
}

resource "aws_ecs_service" "db" {
  name                   = "marquez-db-prv-ip"
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
    target_group_arn = data.aws_lb_target_group.db_tg_prv_ip.arn
    container_name   = "marquez-db"
    container_port   = 5432
  }

  # Depend on the log group and the *existence* of the listener
  depends_on = [
    aws_cloudwatch_log_group.db_logs,
    data.aws_lb_listener.internal_tcp_5432_prv_ip # Now a data source
  ]

  health_check_grace_period_seconds = 60
}

######################
# Auto Scaling (Resources - These are managed by your Terraform config)
# Configures auto-scaling for ECS services based on CPU utilization.
######################
resource "aws_appautoscaling_target" "api_prv_ip" {
  max_capacity       = var.marquez_api_autoscaling_max
  min_capacity       = var.marquez_api_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/marquez-api-prv-ip"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on         = [aws_ecs_service.api]
}

resource "aws_appautoscaling_policy" "api_cpu_prv_ip" {
  name                = "api-prv-ip-cpu-scaling"
  policy_type         = "TargetTrackingScaling"
  resource_id         = aws_appautoscaling_target.api_prv_ip.resource_id
  scalable_dimension  = aws_appautoscaling_target.api_prv_ip.scalable_dimension
  service_namespace   = aws_appautoscaling_target.api_prv_ip.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value           = var.marquez_api_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "web_prv_ip" {
  max_capacity       = var.marquez_web_autoscaling_max
  min_capacity       = var.marquez_web_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/marquez-web-prv-ip"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on         = [aws_ecs_service.web]
}

resource "aws_appautoscaling_policy" "web_cpu_prv_ip" {
  name                = "web-prv-ip-cpu-scaling"
  policy_type         = "TargetTrackingScaling"
  resource_id         = aws_appautoscaling_target.web_prv_ip.resource_id
  scalable_dimension  = aws_appautoscaling_target.web_prv_ip.scalable_dimension
  service_namespace   = aws_appautoscaling_target.web_prv_ip.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value           = var.marquez_web_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}