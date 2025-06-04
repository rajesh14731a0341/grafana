resource "aws_ecs_task_definition" "grafana_task" {
  family                   = "rajesh-grafana-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = var.execution_role_arn
  task_role_arn           = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:11.6.1"
      essential = true
      portMappings = [{ containerPort = 3000, protocol = "tcp" }]
      secrets = [
        { name = "GF_SECURITY_ADMIN_USER", valueFrom = var.grafana_user_secret_arn },
        { name = "GF_SECURITY_ADMIN_PASSWORD", valueFrom = var.grafana_pass_secret_arn }
      ]
      environment = [
        { name = "GF_RENDERING_SERVER_URL", value = "http://localhost:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://localhost:3000" },
        { name = "GF_LOG_FILTERS", value = "rendering:debug" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "REDIS_PATH", value = "localhost:6379" },
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" },
        { name = "CACHING", value = "Y" }
      ]
      mountPoints = [{
        sourceVolume  = "grafana-storage"
        containerPath = "/var/lib/grafana"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/rajesh-grafana"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana"
        }
      }
    },
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:3.12.5"
      essential = false
      portMappings = [{ containerPort = 8081 }]
    },
    {
      name      = "redis"
      image     = "redis:7.2"
      essential = false
      portMappings = [{ containerPort = 6379 }]
      secrets = [
        { name = "REDIS_PASSWORD", valueFrom = var.redis_pass_secret_arn }
      ]
    }
  ])

  volume {
    name = "grafana-storage"
    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "grafana_service" {
  name            = "rajesh-grafana-service"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.grafana_task.arn
  desired_count   = 1

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.grafana_task]
}
