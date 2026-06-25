output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by availability zone"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  description = "Private subnet IDs keyed by availability zone"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.this.arn
}

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN"
  value       = aws_iam_role.ecs_task_role.arn
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "ecs_http_security_group_id" {
  description = "ECS HTTP service security group ID"
  value       = aws_security_group.ecs_http.id
}

output "ecs_internal_security_group_id" {
  description = "ECS internal services security group ID"
  value       = aws_security_group.ecs_internal.id
}

output "gotenberg_security_group_id" {
  description = "Gotenberg security group ID"
  value       = aws_security_group.gotenberg.id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "account_id" {
  description = "AWS account ID"
  value       = local.account_id
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.this.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.this.port
}

output "rds_database" {
  description = "RDS database name"
  value       = aws_db_instance.this.db_name
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.this.username
}

output "db_secret_arn" {
  description = "Secrets Manager secret ARN for DB credentials"
  value       = aws_secretsmanager_secret.db.arn
}

output "s3_bucket_name" {
  description = "S3 bucket name for SolidTime storage"
  value       = aws_s3_bucket.this.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  value       = aws_ecr_repository.this.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.this.name
}

output "alb_dns_name" {
  description = "ALB DNS name for CNAME record"
  value       = aws_lb.this.dns_name
}

output "alb_arn" {
  description = "ALB ARN for listener rules"
  value       = aws_lb.this.arn
}

output "alb_listener_arn" {
  description = "HTTP listener ARN for ACM certificate binding"
  value       = aws_lb_listener.http.arn
}

output "app_secret_arn" {
  description = "Secrets Manager secret ARN for application keys"
  value       = aws_secretsmanager_secret.app.arn
}
