resource "aws_ecs_task_definition" "api" {
  family                   = "marquez-api-prv-ip"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name        = "marquez-api"
    image       = "marquezproject/marquez:0.42.0"
    portMappings = [{ containerPort = 5000 }]
    environment = [
      { name = "MARQUEZ_CONFIG", value = "" },
      { name = "MARQUEZ_POSTGRES_HOST", value = data.aws_lb.internal_nlb.dns_name },
      { name = "MARQUEZ_POSTGRES_PORT", value = "5432" },
      { name = "MARQUEZ_POSTGRES_USER", value = "marquez" },
      { name = "MARQUEZ_POSTGRES_PASSWORD", value = "marquez" },
      { name = "MARQUEZ_POSTGRES_DB", value = "marquez" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.api_logs.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}
