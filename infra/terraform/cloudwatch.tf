resource "aws_cloudwatch_log_group" "http" {
  name              = "/ecs/${local.name_prefix}-http"
  retention_in_days = 30

  tags = {
    Name = "${local.name_prefix}-http"
  }
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/${local.name_prefix}-worker"
  retention_in_days = 30

  tags = {
    Name = "${local.name_prefix}-worker"
  }
}

resource "aws_cloudwatch_log_group" "scheduler" {
  name              = "/ecs/${local.name_prefix}-scheduler"
  retention_in_days = 30

  tags = {
    Name = "${local.name_prefix}-scheduler"
  }
}

resource "aws_cloudwatch_log_group" "gotenberg" {
  name              = "/ecs/${local.name_prefix}-gotenberg"
  retention_in_days = 30

  tags = {
    Name = "${local.name_prefix}-gotenberg"
  }
}
