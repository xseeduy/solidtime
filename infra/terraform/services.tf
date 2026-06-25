resource "aws_ecs_service" "http" {
  name            = "${local.name_prefix}-http"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.http.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for s in aws_subnet.private : s.id]
    security_groups  = [aws_security_group.ecs_http.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.http.arn
    container_name   = "solidtime"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name = "${local.name_prefix}-http"
  }
}

resource "aws_ecs_service" "worker" {
  name            = "${local.name_prefix}-worker"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for s in aws_subnet.private : s.id]
    security_groups  = [aws_security_group.ecs_internal.id]
    assign_public_ip = false
  }

  tags = {
    Name = "${local.name_prefix}-worker"
  }
}

resource "aws_ecs_service" "scheduler" {
  name            = "${local.name_prefix}-scheduler"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.scheduler.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for s in aws_subnet.private : s.id]
    security_groups  = [aws_security_group.ecs_internal.id]
    assign_public_ip = false
  }

  tags = {
    Name = "${local.name_prefix}-scheduler"
  }
}

resource "aws_ecs_service" "gotenberg" {
  name            = "${local.name_prefix}-gotenberg"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.gotenberg.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for s in aws_subnet.private : s.id]
    security_groups  = [aws_security_group.gotenberg.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.gotenberg.arn
  }

  tags = {
    Name = "${local.name_prefix}-gotenberg"
  }
}
