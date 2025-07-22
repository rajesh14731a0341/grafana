locals {
  log_prefix   = "/aws/ecs/us-east-dev-corp-gdap-errorbudget-grafana"
  common_tags  = {
    Project     = "error budget"
    Owner       = "Muthukumar Kunjithapatham"
    CreatedBy   = "rajesh.puchakayala"
    ApprovedBy  = "Muthukumar Kunjithapatham"
    SRNumber    = "10024"
  }
}

resource "aws_cloudwatch_log_group" "grafana_logs" {
  name              = "${local.log_prefix}-grafana"
  retention_in_days = 30
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "renderer_logs" {
  name              = "${local.log_prefix}-renderer"
  retention_in_days = 30
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "redis_logs" {
  name              = "${local.log_prefix}-redis"
  retention_in_days = 30
  tags              = local.common_tags
}


##############################
# Data Sources for Load Balancers and Target Groups
##############################

data "aws_lb" "public_alb" {
  name = var.alb_name
}

data "aws_lb" "internal_nlb" {
  name = var.nlb_name
}

data "aws_lb_listener" "public_listener" {
  load_balancer_arn = data.aws_lb.public_alb.arn
  port              = 80
}

data "aws_lb_listener" "redis_tcp_listener" {
  load_balancer_arn = data.aws_lb.internal_nlb.arn
  port              = 6379
}

data "aws_lb_target_group" "grafana_tg" {
  name = "grafana-tg"
}

data "aws_lb_target_group" "renderer_tg" {
  name = "renderer-tg"
}

data "aws_lb_target_group" "redis_tg" {
  name = "redis-tg"
}

##############################
# Secrets Manager
##############################

data "aws_secretsmanager_secret_version" "db" {
  secret_id = var.db_secret_arn
}

##############################
# ECS Task Definitions
##############################

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "grafana"
      image = var.grafana_image
      portMappings = [{ containerPort = 3000 }]

      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = var.grafana_admin_user },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.grafana_admin_password },
        { name = "GF_SERVER_ROOT_URL", value = "http://${data.aws_lb.public_alb.dns_name}/grafana" },
        { name = "GF_SERVER_SERVE_FROM_SUB_PATH", value = "true" },
        { name = "GF_DATABASE_TYPE", value = "postgres" },
        { name = "GF_DATABASE_HOST", value = var.db_endpoint },
        { name = "GF_DATABASE_NAME", value = "grafana" },
        { name = "GF_DATABASE_USER", value = "grafana" },
        { name = "GF_DATABASE_PASSWORD", value = data.aws_secretsmanager_secret_version.db.secret_string },
        { name = "GF_DATABASE_SSL_MODE", value = "require" },
        { name = "GF_RENDERING_SERVER_URL", value = "http://${data.aws_lb.public_alb.dns_name}/render" },
        { name = "GF_RENDERING_CALLBACK_URL", value = "http://${data.aws_lb.public_alb.dns_name}/grafana" },
        { name = "REDIS_PATH", value = "${data.aws_lb.internal_nlb.dns_name}:6379" },
        { name = "REDIS_DB", value = "1" },
        { name = "REDIS_CACHETIME", value = "12000" },
        { name = "CACHING", value = "Y" },
        { name = "GF_PLUGIN_ALLOW_LOCAL_MODE", value = "true" },
        { name = "GF_LOG_FILTERS", value = "rendering:debug" },
        { name = "GRAFANA_DATASOURCE_BUCKET", value = var.grafana_datasource_bucket },
        { name = "GRAFANA_DATASOURCE_PREFIX", value = var.grafana_datasource_prefix }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.log_prefix}-grafana"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana"
        }
      },

      command = ["/bin/bash", "-c", "/entrypoint.sh"]
    }
  ])
}

resource "aws_ecs_task_definition" "renderer" {
  family                   = "renderer-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "renderer"
      image = "grafana/grafana-image-renderer:latest"
      portMappings = [{ containerPort = 8081 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.log_prefix}-renderer"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "renderer"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "redis" {
  family                   = "redis-task"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name  = "redis"
    image = "redis:latest"
    portMappings = [{ containerPort = 6379 }]
    command = ["redis-server", "--bind", "0.0.0.0"]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "${local.log_prefix}-redis"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "redis"
      }
    }
  }])
}

##############################
# ECS Services
##############################

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = var.grafana_desired_count
  task_definition = aws_ecs_task_definition.grafana.arn

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.grafana_tg.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  enable_execute_command = true
  depends_on             = [data.aws_lb_listener.public_listener]
}

resource "aws_ecs_service" "renderer" {
  name            = "renderer"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = var.renderer_desired_count
  task_definition = aws_ecs_task_definition.renderer.arn

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.renderer_tg.arn
    container_name   = "renderer"
    container_port   = 8081
  }

  enable_execute_command = true
  depends_on             = [data.aws_lb_listener.public_listener]
}

resource "aws_ecs_service" "redis" {
  name            = "redis"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = var.redis_desired_count
  task_definition = aws_ecs_task_definition.redis.arn

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.redis_tg.arn
    container_name   = "redis"
    container_port   = 6379
  }

  enable_execute_command = true
  depends_on             = [data.aws_lb_listener.redis_tcp_listener]
}



##############################
# CLICKHOUSE DATASOURCES
##############################
resource "local_file" "clickhouse_jsons" {
  for_each = var.clickhouse_sources

  content = templatefile("${path.module}/clickhouse-datasource.tpl.json", {
    name = each.key
    host = each.value.host
    port = each.value.port
  })

  filename = "${path.module}/clickhouse-${each.key}.json"
}

resource "aws_s3_object" "clickhouse_jsons" {
  for_each = local_file.clickhouse_jsons

  bucket = var.grafana_datasource_bucket
  key    = "${var.grafana_datasource_prefix}/clickhouse-${each.key}.json"
  source = each.value.filename
  depends_on = [local_file.clickhouse_jsons]
}


##############################
# POSTGRES DATASOURCE
##############################
resource "local_file" "postgres_json" {
  content = templatefile("${path.module}/postgres-datasource.tpl.json", {
    name     = "rds-postgres"
    host     = var.db_endpoint
    port     = 5432
    user     = "rajesh"
    password = data.aws_secretsmanager_secret_version.db.secret_string
    database = "grafana"
    sslmode  = "require"
  })

  filename = "${path.module}/postgres-datasource.json"
}

resource "aws_s3_object" "postgres_json" {
  bucket = var.grafana_datasource_bucket
  key    = "${var.grafana_datasource_prefix}/postgres-datasource.json"
  source = local_file.postgres_json.filename
  depends_on = [local_file.postgres_json]
}


##############################
# REDIS DATASOURCE
##############################
resource "local_file" "redis_json" {
  content = templatefile("${path.module}/redis-datasource.tpl.json", {
    name = "redis"
    host = data.aws_lb.internal_nlb.dns_name
    port = 6379
  })

  filename = "${path.module}/redis-datasource.json"
}

resource "aws_s3_object" "redis_json" {
  bucket = var.grafana_datasource_bucket
  key    = "${var.grafana_datasource_prefix}/redis-datasource.json"
  source = local_file.redis_json.filename
  depends_on = [local_file.redis_json]
}
