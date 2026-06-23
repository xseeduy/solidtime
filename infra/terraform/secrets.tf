resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"

  lifecycle {
    ignore_changes = [special, override_special]
  }
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "${local.name_prefix}-db"
  description             = "RDS PostgreSQL credentials for SolidTime"
  recovery_window_in_days = 0

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = aws_db_instance.this.db_name
    username = aws_db_instance.this.username
    password = random_password.db.result
  })
}

resource "random_password" "app_key" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "app" {
  name                    = "${local.name_prefix}-app"
  description             = "SolidTime application secrets"
  recovery_window_in_days = 0

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    app_key = "base64:${random_password.app_key.result}"
  })
}
