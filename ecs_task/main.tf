resource "aws_ecs_task_definition" "grafana_task" {
  family                   = "rajesh-grafana-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:11.6.1"
      essential = true
      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = var.grafana_user },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.grafana_password },
        { name = "GF_RENDERING_SERVER_URL", value = "http://renderer:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://localhost:3000/" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "CACHING", value = "Y" },
        { name = "REDIS_PATH", value = "redis:6379" },
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" }
      ]
      portMappings = [{ containerPort = 3000, hostPort = 3000 }]
      mountPoints = [{
        sourceVolume  = "grafana_efs"
        containerPath = "/var/lib/grafana"
        readOnly      = false
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/grafana"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana"
        }
      }
    },
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:3.12.5"
      essential = true
      portMappings = [{ containerPort = 8081, hostPort = 8081 }]
      environment = [
        { name = "RENDER_USER", value = var.renderer_user },
        { name = "RENDER_PASS", value = var.renderer_password }
      ]
    },
    {
      name      = "redis"
      image     = "redis:7.2-alpine"
      essential = true
      environment = [
        { name = "REDIS_USER", value = var.redis_user },
        { name = "REDIS_PASSWORD", value = var.redis_password }
      ]
    }
  ])

  volume {
    name = "grafana_efs"
    efs_volume_configuration {
      file_system_id          = var.file_system_id
      authorization_config {
        access_point_id = var.access_point_id
        iam             = "ENABLED"
      }
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_ecs_service" "grafana_service" {
  name            = "rajesh-grafana-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.grafana_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.grafana_task]
}
