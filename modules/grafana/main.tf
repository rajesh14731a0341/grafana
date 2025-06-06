resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "renderer" {
  name              = "/ecs/renderer"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/redis"
  retention_in_days = 14
}

# Grafana Task Definition
resource "aws_ecs_task_definition" "grafana_task" {
  family                   = "grafana-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-enterprise:11.6.1"
      essential = true

      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]

      environment = [
        {
          name  = "GF_DATABASE_TYPE"
          value = "postgres"
        },
        {
          name  = "GF_DATABASE_HOST"
          value = var.db_endpoint
        },
        {
          name  = "GF_DATABASE_NAME"
          value = "grafana"
        },
        {
          name  = "GF_DATABASE_USER"
          value = "rajesh"
        },
        {
          name  = "GF_DATABASE_SSL_MODE"
          value = "require"
        },
        {
          name  = "GF_RENDERING_SERVER_URL"
          value = "http://renderer:8081/render"
        },
        {
          name  = "GF_RENDERING_CALLBACK_URL"
          value = "http://grafana:3000/"
        },
        {
          name  = "REDIS_HOST"
          value = "redis"
        },
        {
          name  = "REDIS_PORT"
          value = "6379"
        },
        {
          name  = "REDIS_DB"
          value = "1"
        },
        {
          name  = "REDIS_CACHETIME"
          value = "12000"
        },
        {
          name  = "CACHING"
          value = "Y"
        },
        {
          name  = "GF_PLUGIN_ALLOW_LOCAL_MODE"
          value = "true"
        }
      ]

      secrets = [
        {
          name      = "GF_DATABASE_PASSWORD"
          valueFrom = var.db_secret_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grafana.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana"
        }
      }

    }
  ])
}

# Renderer Task Definition
resource "aws_ecs_task_definition" "renderer_task" {
  family                   = "renderer-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "renderer"
      image     = "grafana/grafana-image-renderer:3.12.5"
      essential = true

      portMappings = [{
        containerPort = 8081
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.renderer.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "renderer"
        }
      }
    }
  ])
}

# Redis Task Definition
resource "aws_ecs_task_definition" "redis_task" {
  family                   = "redis-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "redis"
      image     = "redis:latest"
      essential = true

      portMappings = [{
        containerPort = 6379
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.redis.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "redis"
        }
      }
    }
  ])
}

# Grafana ECS Service
resource "aws_ecs_service" "grafana_service" {
  name            = "rajesh-grafana-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana_task.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [
    aws_cloudwatch_log_group.grafana
  ]
}

# Renderer ECS Service
resource "aws_ecs_service" "renderer_service" {
  name            = "rajesh-renderer-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer_task.arn
  desired_count   = var.renderer_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [
    aws_cloudwatch_log_group.renderer
  ]
}

# Redis ECS Service
resource "aws_ecs_service" "redis_service" {
  name            = "rajesh-redis-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis_task.arn
  desired_count   = var.redis_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [
    aws_cloudwatch_log_group.redis
  ]
}

##############################
# Auto Scaling for Grafana
##############################

resource "aws_appautoscaling_target" "grafana_scaling_target" {
  max_capacity       = var.grafana_autoscaling_max
  min_capacity       = var.grafana_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.grafana_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grafana_cpu_policy" {
  name               = "grafana-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.grafana_autoscaling_cpu_target
  }
}

##############################
# Auto Scaling for Renderer
##############################

resource "aws_appautoscaling_target" "renderer_scaling_target" {
  max_capacity       = var.renderer_autoscaling_max
  min_capacity       = var.renderer_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.renderer_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "renderer_cpu_policy" {
  name               = "renderer-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.renderer_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.renderer_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.renderer_autoscaling_cpu_target
  }
}

##############################
# Auto Scaling for Redis
##############################

resource "aws_appautoscaling_target" "redis_scaling_target" {
  max_capacity       = var.redis_autoscaling_max
  min_capacity       = var.redis_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.redis_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "redis_cpu_policy" {
  name               = "redis-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.redis_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.redis_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.redis_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.redis_autoscaling_cpu_target
  }
}
