resource "aws_ecs_task_definition" "grafana" {
  family                   = "rajesh-grafana-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = var.grafana_image
      essential = true
      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]
      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = var.grafana_user },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.grafana_password }
      ]
      mountPoints = [{
        sourceVolume  = "grafana_data"
        containerPath = "/var/lib/grafana"
        readOnly      = false
      }]
    },
    {
      name      = "renderer"
      image     = var.renderer_image
      essential = true
      portMappings = [{
        containerPort = 8081
        protocol      = "tcp"
      }]
      environment = [
        { name = "RENDERER_USER", value = var.renderer_user },
        { name = "RENDERER_PASSWORD", value = var.renderer_password }
      ]
    },
    {
      name      = "redis"
      image     = var.redis_image
      essential = true
      portMappings = [{
        containerPort = 6379
        protocol      = "tcp"
      }]
      environment = [
        { name = "REDIS_USER", value = var.redis_user },
        { name = "REDIS_PASSWORD", value = var.redis_password }
      ]
    }
  ])

  volume {
    name = "grafana_data"
    efs_volume_configuration {
      file_system_id = var.efs_file_system_id
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "ENABLED"
      }
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "rajesh-grafana-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  depends_on = [aws_ecs_task_definition.grafana]
}
