######################
# CloudWatch Log Groups
######################
resource "aws_cloudwatch_log_group" "vector_logs" {
  name              = "/ecs/vector"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "clickhouse_logs" {
  name              = "/ecs/clickhouse"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "nginx_logs" {
  name              = "/ecs/nginx"
  retention_in_days = 7
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
data "aws_lb_listener" "public_http" {
  load_balancer_arn = data.aws_lb.public_alb.arn
  port              = 80
}

######################
# Target Groups
######################
resource "aws_lb_target_group" "clickhouse_tg" {
  name        = "d3po-clickhouse-tg"
  port        = 8123
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}


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

resource "aws_lb_target_group" "vector_tg" {
  name        = "d3po-vector-tg"
  port        = 8686
  protocol    = "TCP"  # ✅ FIX: Change from HTTP to TCP
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "TCP"     # ✅ TCP health check, since protocol is TCP
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}


######################
# Listeners
######################
resource "aws_lb_listener" "clickhouse_tcp_8123" {
  load_balancer_arn = data.aws_lb.internal_nlb.arn
  port              = 8123
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clickhouse_tg.arn
  }
}

resource "aws_lb_listener_rule" "nginx_vector_path_rule" {
  listener_arn = data.aws_lb_listener.public_http.arn
  priority     = 60

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_vector_tg.arn
  }

  condition {
    path_pattern {
      values = ["/ol-vector*", "/healthz"]
    }
  }
}

resource "aws_lb_listener" "vector_TCP_8686" {
  load_balancer_arn = data.aws_lb.internal_nlb.arn
  port              = 8686
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vector_tg.arn
  }
}

######################
# S3 Objects
######################

locals {
  s3_bucket        = "errorbudget-s3"
  s3_common_prefix = "errorbudget-terraform-tfstate/d3po-marquez" # ✅ no trailing slash
}

resource "aws_s3_object" "vector_config" {
  bucket       = local.s3_bucket
  key          = "${local.s3_common_prefix}/vector.yaml"
  source       = abspath("${path.root}/../../docker/vector/vector.yaml")
  etag         = filemd5(abspath("${path.root}/../../docker/vector/vector.yaml"))
  content_type = "text/yaml"
  tags         = {}

  lifecycle {
   ignore_changes  = [tags]
  }
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
# Task Definitions
######################
resource "aws_ecs_task_definition" "vector" {
  family                   = "d3po-vector"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "vector"
      image     = var.vector_image
      essential = true

      portMappings = [
        {
          containerPort = 8686
          hostPort      = 8686
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "AWS_REGION"
          value = var.region
        },
        {
          name  = "VECTOR_CONFIG_BUCKET"
          value = var.vector_config_bucket
        },
        {
          name  = "VECTOR_CONFIG_PREFIX"
          value = var.vector_config_prefix
        },
        {
          name  = "CLICKHOUSE_HOST"
          value = data.aws_lb.internal_nlb.dns_name
        },
        {
          name  = "MARQUEZ_API_HOST"
          value = data.aws_lb.public_alb.dns_name
        },
        {
          name  = "MARQUEZ_API_PATH"
          value = "/api/v1/lineage"
        }
      ]

      entryPoint = ["sh", "-c"]
      command = [
        <<-EOF
        set -e
        echo "Downloading Vector config from S3..."
        aws s3 cp s3://$${VECTOR_CONFIG_BUCKET}/$${VECTOR_CONFIG_PREFIX}/vector.yaml /etc/vector/vector.yaml
        echo "Starting Vector..."
        exec vector --config /etc/vector/vector.yaml
        EOF
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.vector_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_task_definition" "clickhouse" {
  family                   = "d3po-clickhouse"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "clickhouse"
    image       = "clickhouse/clickhouse-server:23.4"
    portMappings = [
      { containerPort = 8123 }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.clickhouse_logs.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

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
        {
          name  = "NGINX_CONFIG_BUCKET_VAR"
          value = var.nginx_config_bucket 
        },
        {
          name  = "NGINX_CONFIG_PREFIX"
          value = var.nginx_config_prefix  
        },
        {
          name  = "OL_VECTOR_HOST"
          value = data.aws_lb.internal_nlb.dns_name
        },
        {
          name  = "OL_VECTOR_PORT"
          value = "8686"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.nginx_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


######################
# ECS Services
######################
resource "aws_ecs_service" "vector" {
  name                   = "d3po-vector"
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

  load_balancer {
    target_group_arn = aws_lb_target_group.vector_tg.arn
    container_name   = "vector"
    container_port   = 8686
  }

  depends_on = [
    aws_ecs_task_definition.vector,
    aws_cloudwatch_log_group.vector_logs,
    aws_s3_object.vector_config,
    aws_lb_listener.vector_TCP_8686  # Ensure listener is ready before service
  ]

  health_check_grace_period_seconds = 60
}


resource "aws_ecs_service" "clickhouse" {
  name                   = "d3po-clickhouse"
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.clickhouse.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.clickhouse_tg.arn
    container_name   = "clickhouse"
    container_port   = 8123
  }

  depends_on = [
    aws_lb_listener.clickhouse_tcp_8123,
    aws_cloudwatch_log_group.clickhouse_logs
  ]

  health_check_grace_period_seconds = 60
}

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
    aws_s3_object.nginx_template
  ]

  health_check_grace_period_seconds = 60
}

######################
# Auto Scaling
######################
resource "aws_appautoscaling_target" "vector" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.vector.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.vector]
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

