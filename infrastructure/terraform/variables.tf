variable "aws_region" {
  description = "AWS region to deploy infrastructure"
  default     = "us-east-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  default     = "tradestack"
}

variable "key_name" {
  description = "AWS key pair name for SSH access"
  default     = "karthik-devops-key"
}

variable "disk_size" {
  description = "EC2 root volume size in GB"
  default     = 20
}
