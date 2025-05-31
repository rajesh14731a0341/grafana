resource "aws_ecs_task_definition" "rajesh_grafana_task" {
  family                   = "rajesh-grafana-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:latest"
      essential = true
      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]
      environment = [
        { name = "GF_SECURITY_ADMIN_USER",  value = var.grafana_user },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.grafana_password }
      ]
    },
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:latest"
      essential = false
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
      image     = "redis:latest"
      essential = false
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
}
