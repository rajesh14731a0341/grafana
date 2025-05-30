resource "aws_ecs_service" "rajesh_grafana_service" {
  name            = "rajesh-grafana-service"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = var.task_definition_arn

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }
}
