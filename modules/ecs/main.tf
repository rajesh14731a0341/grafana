resource "aws_ecs_task_definition" "grafana_stack" {
  family             = "grafana-stack"
  network_mode       = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                = 1024
  memory             = 2048
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = var.grafana_image
      ports     = [{ containerPort = 3000, hostPort = 3000 }]
      volumes   = [
        {
          name      = "grafana-storage"
          hostPath  = "/var/lib/grafana"
        },
        {
          name      = "grafana-provisioning"
          hostPath  = "/etc/grafana/provisioning"
        },
        {
          name      = "grafana-ini"
          hostPath  = "/etc/grafana/grafana.ini"
        },
        {
          name      = "grafana-plugins"
          hostPath  = "/var/lib/grafana/plugins"
        }
      ]
      environment = [
        {
          name  = "REDIS_PATH"
          value = "${var.redis_container_name}:6379"
        },
        {
          name  = "REDIS_DB"
          value = "1"
        },
        {
          name  = "REDIS_CACHETIME"
          value = "12000"
        },
        {
          name  = "CACHING"
          value = "Y"
        },
        {
          name  = "GF_PLUGIN_ALLOW_LOCAL_MODE"
          value = "true"
        },
        {
          name  = "GF_RENDERING_SERVER_URL"
          value = "http://${var.renderer_container_name}:8081/render"
        },
        {
          name  = "GF_RENDERING_CALLBACK_URL"
          value = "http://grafana:3000/"
        },
        {
          name  = "GF_LOG_FILTERS"
          value = "rendering:debug"
        },
        {
          name  = "GF_AUTH_ADMIN_USER"
          value = var.grafana_user
        },
        {
          name  = "GF_AUTH_ADMIN_PASSWORD"
          value = var.grafana_password
        }
      ]
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group  = "/ecs/${var.ecs_cluster_id}/grafana"
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "grafana"
        }
      }
    },
    {
      name      = var.renderer_container_name
      image     = var.renderer_image
      ports     = [{ containerPort = 8081, hostPort = 8081 }]
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group  = "/ecs/${var.ecs_cluster_id}/${var.renderer_container_name}"
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "renderer"
        }
      }
    },
    {
      name      = var.redis_container_name
      image     = var.redis_image
      ports     = [{ containerPort = 6379, hostPort = 6379 }]
      environment = [
        {
          name  = "REDISUSER"
          value = var.redis_user
        },
        {
          name  = "REDISPASSWORD"
          value = var.redis_password
        }
      ]
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group  = "/ecs/${var.ecs_cluster_id}/${var.redis_container_name}"
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "redis"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "grafana_service" {
  name            = "grafana-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana_stack.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true # Set to false if you have a private subnet and NAT gateway
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_lb" "grafana" {
  name               = "grafana-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "grafana" {
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
    interval = 30
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.grafana.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

data "aws_vpc" "default" {
  default = true
}