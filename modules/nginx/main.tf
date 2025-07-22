
######################
# Load Balancers
######################
data "aws_lb" "public_alb" {
  name = var.public_alb_name
}

data "aws_lb" "internal_alb" {
  name = var.internal_alb_name
}
data "aws_lb" "internal_nlb" {
  name = var.nlb_name
}
data "aws_lb_listener" "public_http" {
  load_balancer_arn = data.aws_lb.public_alb.arn
  port              = 80
}

data "aws_lb_listener" "internal_listener" {
  load_balancer_arn = data.aws_lb.internal_alb.arn
  port              = 80
}
######################
# Target Groups
######################
resource "aws_lb_target_group" "nginx_vector_tg" {
  name        = "nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

######################
# Listeners
######################

resource "aws_lb_listener_rule" "nginx_vector_path_rule" {
  listener_arn = data.aws_lb_listener.public_http.arn
  priority     = 60

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_vector_tg.arn
  }

  condition {
    path_pattern {
      values = ["/d3po/api/*", "/promodb/api/*", "/healthz"]
    }
  }
}


######################
# S3 Objects
######################

locals {
  s3_bucket        = "errorbudget-s3"
  s3_common_prefix = "errorbudget-terraform-tfstate/marquez_config" # ✅ no trailing slash
}


resource "aws_s3_object" "nginx_template" {
  bucket       = local.s3_bucket
  key          = "${local.s3_common_prefix}/nginx.template"
  source       = abspath("${path.root}/../../docker/nginx/nginx.template")
  etag         = filemd5(abspath("${path.root}/../../docker/nginx/nginx.template"))
  content_type = "text/plain"
  tags         = {}

  lifecycle {
    ignore_changes  = [tags]
  }
}

resource "aws_s3_object" "proxy_headers_conf" {
  bucket       = local.s3_bucket
  key          = "${local.s3_common_prefix}/proxy-headers.conf"
  source       = abspath("${path.root}/../../docker/nginx/proxy-headers.conf")
  etag         = filemd5(abspath("${path.root}/../../docker/nginx/proxy-headers.conf"))
  content_type = "text/plain"
  tags         = {}

  lifecycle {
    ignore_changes  = [tags]
  }
}

######################
# CloudWatch Log Groups
######################
locals {
  common_tags = {
    Project     = "error budget"
    Owner       = "Muthukumar Kunjithapatham"
    CreatedBy   = "rajesh.puchakayala"
    ApprovedBy  = "Muthukumar Kunjithapatham"
    SRNumber    = "10024"
  }
}
resource "aws_cloudwatch_log_group" "nginx_logs" {
  name              = "/aws/ecs/us-east-dev-corp-gdap-errorbudget-nginx"
  retention_in_days = 30
  tags              = local.common_tags
}

######################
# Task Definitions
######################

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx-proxy"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = var.nginx_image
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        # S3 config
        {
          name  = "NGINX_CONFIG_BUCKET_VAR"
          value = var.nginx_config_bucket
        },
        {
          name  = "NGINX_CONFIG_PREFIX"
          value = var.nginx_config_prefix
        },

        # Vector routing - internal NLB
        {
          name  = "D3PO_VECTOR_HOST"
          value = data.aws_lb.internal_nlb.dns_name
        },
        {
          name  = "D3PO_VECTOR_PORT"
          value = "8686"
        },
        {
          name  = "PROMODB_VECTOR_HOST"
          value = data.aws_lb.internal_nlb.dns_name
        },
        {
          name  = "PROMODB_VECTOR_PORT"
          value = "8687"
        },

        # Marquez API routing - public ALB
        {
          name  = "D3PO_MARQUEZ_API_HOST"
          value = data.aws_lb.internal_alb.dns_name
        },
        {
          name  = "PROMODB_MARQUEZ_API_HOST"
          value = data.aws_lb.internal_alb.dns_name
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.nginx_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "nginx"
        }
      }
    }
  ])
}



######################
# ECS Services
######################

resource "aws_ecs_service" "nginx" {
  name                   = "nginx"
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.nginx.arn
  desired_count          = var.nginx_desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_vector_tg.arn
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener_rule.nginx_vector_path_rule,
    aws_cloudwatch_log_group.nginx_logs,
    aws_s3_object.nginx_template,
    aws_s3_object.proxy_headers_conf
  ]

  health_check_grace_period_seconds = 60
}

######################
# Auto Scaling
######################

resource "aws_appautoscaling_target" "nginx" {
  min_capacity       = var.nginx_autoscaling_min
  max_capacity       = var.nginx_autoscaling_max
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.nginx.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.nginx]
}


resource "aws_appautoscaling_policy" "nginx_cpu" {
  name               = "nginx-cpu-autoscaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.nginx.resource_id
  scalable_dimension = aws_appautoscaling_target.nginx.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.nginx_autoscaling_cpu_target
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

