resource "aws_ecs_task_definition" "grafana" {
  family                   = "rajeshso-grafana-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:11.6.1"
      portMappings = [{ containerPort = 3000, hostPort = 3000 }]
      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = var.grafana_user },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.grafana_password },
        { name = "GF_RENDERING_SERVER_URL", value = "http://localhost:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://localhost:3000/" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" }
      ]
      mountPoints = [{
        containerPath = "/var/lib/grafana",
        sourceVolume  = "grafana-data"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/rajeshso-grafana"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:3.12.5"
      portMappings = [{ containerPort = 8081, hostPort = 8081 }]
      environment = [
        { name = "RENDERER_USER", value = var.renderer_user },
        { name = "RENDERER_PASSWORD", value = var.renderer_password }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/rajeshso-grafana"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name      = "redis"
      image     = "redis:7"
      portMappings = [{ containerPort = 6379, hostPort = 6379 }]
      environment = [
        { name = "REDIS_USER", value = var.redis_user },
        { name = "REDIS_PASSWORD", value = var.redis_password }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/rajeshso-grafana"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  volume {
    name = "grafana-data"
    efs_volume_configuration {
      file_system_id          = var.filesystem_id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = var.access_point_id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "rajeshso-grafana-service"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.grafana]
}
