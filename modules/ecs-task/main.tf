resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = var.grafana_image
      essential = true
      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = var.grafana_user },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.grafana_password },
        { name = "REDIS_PATH", value = "redis:6379" },
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" },
        { name = "CACHING", value = "Y" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "GF_RENDERING_SERVER_URL", value = "http://renderer:8081/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana:3000/" },
        { name = "GF_LOG_FILTERS", value = "rendering:debug" }
      ]
      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "grafana"
        }
      }
      mountPoints = [{
        containerPath = "/var/lib/grafana"
        sourceVolume  = "grafana_data"
        readOnly      = false
      }]
    },
    {
      name      = "renderer"
      image     = var.renderer_image
      essential = false
      environment = [
        { name = "RENDERER_USER", value = var.renderer_user },
        { name = "RENDERER_PASSWORD", value = var.renderer_password }
      ]
      portMappings = [{
        containerPort = 8081
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "renderer"
        }
      }
    },
    {
      name      = "redis"
      image     = var.redis_image
      essential = true
      environment = [
        { name = "REDIS_USER", value = var.redis_user },
        { name = "REDIS_PASSWORD", value = var.redis_password }
      ]
      portMappings = [{
        containerPort = 6379
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "redis"
        }
      }
    }
  ])

  volume {
    name = "grafana_data"

    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "DISABLED"
      }
      root_directory          = "/grafana"
    }
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "grafana-service"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  depends_on = [aws_ecs_task_definition.grafana]
}
