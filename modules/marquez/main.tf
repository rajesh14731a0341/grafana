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
# Listeners
######################
data "aws_lb_listener" "public_http" {
  load_balancer_arn = data.aws_lb.public_alb.arn
  port              = 80
}

resource "aws_lb_listener" "internal_tcp_5432_prv_ip" {
  load_balancer_arn = data.aws_lb.internal_nlb.arn
  port              = 5432
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.db_tg_prv_ip.arn
  }
}

######################
# Target Groups
######################
resource "aws_lb_target_group" "api_tg_prv_ip" {
  name        = "marquez-api-prv-ip-tg"
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

resource "aws_lb_target_group" "web_tg_prv_ip" {
  name        = "marquez-web-prv-ip-tg"
  port        = 3000
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

resource "aws_lb_target_group" "db_tg_prv_ip" {
  name        = "marquez-db-prv-ip-tg"
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

######################
# Listener Rules
######################
resource "aws_lb_listener_rule" "api_rule_prv_ip" {
  listener_arn = data.aws_lb_listener.public_http.arn
  priority     = 1006

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg_prv_ip.arn
  }

  condition {
    path_pattern {
      values = ["/api*", "/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "web_rule_prv_ip" {
  listener_arn = data.aws_lb_listener.public_http.arn
  priority     = 1007

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg_prv_ip.arn
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
    target_group_arn = aws_lb_target_group.api_tg_prv_ip.arn
    container_name   = "marquez-api"
    container_port   = 5000
  }

  depends_on = [
    aws_lb_listener_rule.api_rule_prv_ip,
    aws_cloudwatch_log_group.api_logs
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
    target_group_arn = aws_lb_target_group.web_tg_prv_ip.arn
    container_name   = "marquez-web"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener_rule.web_rule_prv_ip,
    aws_cloudwatch_log_group.web_logs
  ]

  health_check_grace_period_seconds = 60
}

resource "aws_ecs_service" "db" {
  name                   = "marquez-db-prv-ip"
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.db.arn
  desired_count          = 0
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.db_tg_prv_ip.arn
    container_name   = "marquez-db"
    container_port   = 5432
  }

  depends_on = [
    aws_lb_listener.internal_tcp_5432_prv_ip,
    aws_cloudwatch_log_group.db_logs
  ]

  health_check_grace_period_seconds = 60
}

######################
# Auto Scaling
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
    target_value = var.marquez_api_autoscaling_cpu_target
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
    target_value = var.marquez_web_autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}


#################################################################

resource "aws_s3_object" "vector_config" {
  bucket = var.vector_config_bucket
  key    = "vector.yaml"
  source = "${path.module}/../../docker/vector.yaml"
  etag   = filemd5("${path.module}/../../docker/vector.yaml")
}

resource "aws_cloudwatch_log_group" "vector_logs" {
  name              = "/ecs/vector-prv-ip"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "vector" {
  family                   = "vector-prv-ip"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "vector"
    image     = "timberio/vector:0.39.0-alpine"
    essential = true
    portMappings = [
      { containerPort = 8686 }
    ]
    environment = [
      {
        name  = "AWS_REGION"
        value = var.region
      }
    ]
    command = [
      "sh",
      "-c",
      "aws s3 cp s3://${var.vector_config_bucket}/vector.yaml /etc/vector/vector.yaml && vector"
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.vector_logs.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "vector" {
  name                   = "vector-prv-ip"
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.vector.arn
  desired_count          = var.vector_desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  depends_on = [
    aws_ecs_task_definition.vector,
    aws_cloudwatch_log_group.vector_logs,
    aws_s3_object.vector_config
  ]

  health_check_grace_period_seconds = 60
}

resource "aws_appautoscaling_target" "vector" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/vector-prv-ip"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "vector_cpu" {
  name               = "vector-cpu-autoscaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.vector.resource_id
  scalable_dimension = aws_appautoscaling_target.vector.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
