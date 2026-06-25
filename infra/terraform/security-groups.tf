resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb"
  description = "ALB for SolidTime HTTP service"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

resource "aws_security_group" "ecs_http" {
  name        = "${local.name_prefix}-ecs-http"
  description = "SolidTime HTTP service"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-ecs-http"
  }
}

resource "aws_security_group" "ecs_internal" {
  name        = "${local.name_prefix}-ecs-internal"
  description = "SolidTime worker and scheduler services"
  vpc_id      = aws_vpc.this.id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-ecs-internal"
  }
}

resource "aws_security_group" "gotenberg" {
  name        = "${local.name_prefix}-gotenberg"
  description = "Gotenberg PDF service"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Gotenberg API from ECS services"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [
      aws_security_group.ecs_http.id,
      aws_security_group.ecs_internal.id,
    ]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-gotenberg"
  }
}

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds"
  description = "RDS PostgreSQL for SolidTime"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "PostgreSQL from ECS services"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [
      aws_security_group.ecs_http.id,
      aws_security_group.ecs_internal.id,
    ]
  }

  tags = {
    Name = "${local.name_prefix}-rds"
  }
}
