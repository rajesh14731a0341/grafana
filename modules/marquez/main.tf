
resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "marquez-db",
      image     = "postgres:14",
      essential = true,
      environment = [
        { name = "POSTGRES_USER",     value = "marquez" },
        { name = "POSTGRES_PASSWORD", value = "marquez" },
        { name = "POSTGRES_DB",       value = "marquez" }
      ],
      portMappings = [{ containerPort = 5432 }],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = "us-east-1",
          awslogs-group         = "/ecs/${var.service_name}",
          awslogs-stream-prefix = "marquez-db",
          awslogs-create-group  = "true"
        }
      }
    },
    {
      name      = "marquez-api",
      image     = "marquezproject/marquez:0.47.0",
      essential = true,
      portMappings = [
        { containerPort = 5000 },
        { containerPort = 5001 }
      ],
      command = ["server"],
      dependsOn = [{ containerName = "marquez-db", condition = "START" }],
      environment = [
        { name = "MARQUEZ_DB_URL",      value = "jdbc:postgresql://marquez-db:5432/marquez" },
        { name = "MARQUEZ_DB_USER",     value = "marquez" },
        { name = "MARQUEZ_DB_PASSWORD", value = "marquez" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = "us-east-1",
          awslogs-group         = "/ecs/${var.service_name}",
          awslogs-stream-prefix = "marquez-api",
          awslogs-create-group  = "true"
        }
      }
    },
    {
      name      = "marquez-web",
      image     = "marquezproject/marquez-web:0.47.0",
      essential = true,
      portMappings = [{ containerPort = 3000 }],
      dependsOn = [{ containerName = "marquez-api", condition = "START" }],
      environment = [
        { name = "MARQUEZ_HOST", value = "localhost" },
        { name = "MARQUEZ_PORT", value = "5000" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = "us-east-1",
          awslogs-group         = "/ecs/${var.service_name}",
          awslogs-stream-prefix = "marquez-web",
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name                   = var.service_name
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = var.assign_public_ip
  }
}

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.autoscaling_max
  min_capacity       = var.autoscaling_min
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "cpu-scaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  policy_type = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
