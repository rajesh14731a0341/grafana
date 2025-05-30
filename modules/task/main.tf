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
      portMappings = [{ containerPort = 3000 }]
    },
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:latest"
      essential = false
      portMappings = [{ containerPort = 8081 }]
    },
    {
      name      = "redis"
      image     = "redis:latest"
      essential = false
      portMappings = [{ containerPort = 6379 }]
    }
  ])
}
