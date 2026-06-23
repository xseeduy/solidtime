variable "aws_region" {
  description = "AWS region for all infrastructure resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name used as resource name suffix"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name used for resource naming prefix"
  type        = string
  default     = "xseed-solidtime"
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnet placement"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets, keyed by availability zone"
  type        = map(string)
  default = {
    "us-east-1a" = "10.0.1.0/24"
    "us-east-1b" = "10.0.2.0/24"
  }
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets, keyed by availability zone"
  type        = map(string)
  default = {
    "us-east-1a" = "10.0.10.0/24"
    "us-east-1b" = "10.0.11.0/24"
  }
}
