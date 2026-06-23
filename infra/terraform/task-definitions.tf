locals {
  solidtime_image = var.image_tag != "" ? "${aws_ecr_repository.this.repository_url}:${var.image_tag}" : "${aws_ecr_repository.this.repository_url}:latest"

  solidtime_env_vars = [
    { name = "APP_ENV", value = "production" },
    { name = "APP_DEBUG", value = "false" },
    { name = "APP_URL", value = "http://${aws_lb.this.dns_name}" },
    { name = "APP_FORCE_HTTPS", value = "false" },
    { name = "OCTANE_SERVER", value = "frankenphp" },
    { name = "TRUSTED_PROXIES", value = "*" },
    { name = "DB_CONNECTION", value = "pgsql" },
    { name = "DB_HOST", value = aws_db_instance.this.address },
    { name = "DB_PORT", value = tostring(aws_db_instance.this.port) },
    { name = "DB_DATABASE", value = aws_db_instance.this.db_name },
    { name = "DB_USERNAME", value = aws_db_instance.this.username },
    { name = "QUEUE_CONNECTION", value = "database" },
    { name = "CACHE_STORE", value = "database" },
    { name = "SESSION_DRIVER", value = "database" },
    { name = "FILESYSTEM_DISK", value = "s3" },
    { name = "PUBLIC_FILESYSTEM_DISK", value = "s3" },
    { name = "AWS_BUCKET", value = aws_s3_bucket.this.bucket },
    { name = "AWS_DEFAULT_REGION", value = var.aws_region },
    { name = "MAIL_MAILER", value = "ses" },
    { name = "GOTENBERG_URL", value = "http://gotenberg.solidtime.local:3000" },
    { name = "AUTO_DB_MIGRATE", value = "true" },
  ]

  solidtime_secrets = [
    { name = "DB_PASSWORD", valueFrom = "${aws_secretsmanager_secret.db.arn}:password::" },
    { name = "APP_KEY", valueFrom = "${aws_secretsmanager_secret.app.arn}:app_key::" },
  ]
}

resource "aws_ecs_task_definition" "http" {
  family                   = "${local.name_prefix}-http"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "solidtime"
      image     = local.solidtime_image
      essential = true

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      environment = concat(
        local.solidtime_env_vars,
        [{ name = "CONTAINER_MODE", value = "http" }]
      )

      secrets = local.solidtime_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.name_prefix}-http"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "solidtime"
        }
      }
    }
  ])

  tags = {
    Name = "${local.name_prefix}-http"
  }
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${local.name_prefix}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "solidtime"
      image     = local.solidtime_image
      essential = true

      environment = concat(
        local.solidtime_env_vars,
        [
          { name = "CONTAINER_MODE", value = "worker" },
          { name = "WORKER_COMMAND", value = "php artisan queue:work --sleep=3 --tries=3 --max-time=3600" },
        ]
      )

      secrets = local.solidtime_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.name_prefix}-worker"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "solidtime"
        }
      }
    }
  ])

  tags = {
    Name = "${local.name_prefix}-worker"
  }
}

resource "aws_ecs_task_definition" "scheduler" {
  family                   = "${local.name_prefix}-scheduler"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "solidtime"
      image     = local.solidtime_image
      essential = true

      environment = concat(
        local.solidtime_env_vars,
        [{ name = "CONTAINER_MODE", value = "scheduler" }]
      )

      secrets = local.solidtime_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.name_prefix}-scheduler"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "solidtime"
        }
      }
    }
  ])

  tags = {
    Name = "${local.name_prefix}-scheduler"
  }
}

resource "aws_ecs_task_definition" "gotenberg" {
  family                   = "${local.name_prefix}-gotenberg"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "gotenberg"
      image     = "gotenberg/gotenberg:8"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.name_prefix}-gotenberg"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "gotenberg"
        }
      }
    }
  ])

  tags = {
    Name = "${local.name_prefix}-gotenberg"
  }
}
