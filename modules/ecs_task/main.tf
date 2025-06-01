resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/rajeshso-grafana-task"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "grafana_task" {
  family                   = "rajeshso-grafana-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "grafana"
      image = "grafana/grafana-enterprise"
      portMappings = [{ containerPort = 3000 }]
      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = var.grafana_user },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.grafana_password }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana"
        }
      }
    },
    {
      name  = "renderer"
      image = "grafana/grafana-image-renderer"
      portMappings = [{ containerPort = 8081 }]
      environment = [
        { name = "RENDERER_USER", value = var.renderer_user },
        { name = "RENDERER_PASSWORD", value = var.renderer_password }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "renderer"
        }
      }
    },
    {
      name  = "redis"
      image = "redis"
      portMappings = [{ containerPort = 6379 }]
      environment = [
        { name = "REDIS_USER", value = var.redis_user },
        { name = "REDIS_PASSWORD", value = var.redis_password }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "redis"
        }
      }
    }
  ])
}
