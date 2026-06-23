resource "aws_db_subnet_group" "this" {
  name       = local.name_prefix
  subnet_ids = [for s in aws_subnet.private : s.id]

  tags = {
    Name = local.name_prefix
  }
}

resource "aws_db_parameter_group" "this" {
  name   = local.name_prefix
  family = "postgres15"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = {
    Name = local.name_prefix
  }
}

resource "aws_db_instance" "this" {
  identifier = local.name_prefix

  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t4g.small"

  db_name  = "solidtime"
  username = "solidtime"
  password = random_password.db.result

  port = 5432

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.this.name

  backup_retention_period = 7
  backup_window           = "04:00-05:00"
  maintenance_window      = "sun:05:00-sun:06:00"

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name_prefix}-final"

  publicly_accessible = false

  tags = {
    Name = local.name_prefix
  }
}
