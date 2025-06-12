###############################
# CloudWatch Log Groups
###############################

resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/redis-task"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "renderer" {
  name              = "/ecs/renderer-task"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana-task"
  retention_in_days = 7
}


###############################
# Redis ECS
###############################
resource "aws_ecs_task_definition" "redis" {
  family                   = "redis-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "redis"
    image     = "redis:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 6379
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/redis-task"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "redis"
      }
    }
  }])
}

resource "aws_service_discovery_service" "redis" {
  name         = "redis"
  namespace_id = var.cloudmap_namespace_id

  dns_config {
    namespace_id   = var.cloudmap_namespace_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "redis" {
  name            = "rajesh-2-redis-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = var.redis_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.redis.arn
  }
}

###############################
# Renderer ECS
###############################
resource "aws_ecs_task_definition" "renderer" {
  family                   = "renderer-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "renderer"
    image     = "grafana/grafana-image-renderer:3.12.5"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 8081
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/renderer-task"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "renderer"
      }
    }
  }])
}

resource "aws_service_discovery_service" "renderer" {
  name         = "renderer"
  namespace_id = var.cloudmap_namespace_id

  dns_config {
    namespace_id   = var.cloudmap_namespace_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "renderer" {
  name            = "rajesh-2-renderer-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count   = var.renderer_desired_count
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.renderer.arn
  }
}

###############################
# Grafana ECS
###############################
data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = var.db_secret_arn
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "grafana"
    image     = "grafana/grafana-enterprise:11.6.1"
    cpu       = 512
    memory    = 1024
    essential = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    environment = [
      { name = "GF_DATABASE_TYPE",         value = "postgres" },
      { name = "GF_DATABASE_HOST",         value = "grafana-rds.c030msui2s50.us-east-1.rds.amazonaws.com" },
      { name = "GF_DATABASE_NAME",         value = "grafana" },
      { name = "GF_DATABASE_USER",         value = "rajesh" },
      { name = "GF_DATABASE_PASSWORD",     value = data.aws_secretsmanager_secret_version.db_secret.secret_string },
      { name = "GF_DATABASE_SSL_MODE",     value = "require" },
      { name = "REDIS_PATH",               value = "redis.${var.cloudmap_namespace}:6379" },
      { name = "REDIS_DB",                 value = "1" },
      { name = "REDIS_CACHETIME",          value = "12000" },
      { name = "CACHING",                  value = "Y" },
      { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
      { name = "GF_RENDERING_SERVER_URL",  value = "http://renderer.${var.cloudmap_namespace}:8081/render" },
      { name = "GF_RENDERING_CALLBACK_URL", value = "http://grafana.${var.cloudmap_namespace}:3000/" },
      { name = "GF_LOG_FILTERS",           value = "rendering: debug" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/grafana-task"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "grafana"
      }
    }
  }])
}

resource "aws_service_discovery_service" "grafana" {
  name         = "grafana"
  namespace_id = var.cloudmap_namespace_id

  dns_config {
    namespace_id   = var.cloudmap_namespace_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "rajesh-2-grafana-svc"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.grafana.arn
  }
}
