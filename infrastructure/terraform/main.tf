# ── PROVIDER ─────────────────────────────────────────────────
provider "aws" {
  region = var.aws_region
}

# ── SECURITY GROUP ────────────────────────────────────────────
# Firewall rules - who can access what
resource "aws_security_group" "tradestack_sg" {
  name        = "${var.project_name}-sg-${var.environment}"
  description = "TradeStack security group"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana dashboard
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
    Environment = var.environment
  }
}

# ── EC2 INSTANCE ──────────────────────────────────────────────
resource "aws_instance" "tradestack_server" {
  ami                    = "ami-09cdbb1de48dd8f3c"  # Ubuntu 22.04 LTS us-east-2
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.tradestack_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.tradestack_profile.name

  root_block_device {
    volume_size = var.disk_size
    volume_type = "gp3"
  }

  tags = {
    Name        = "${var.project_name}-server"
    Environment = var.environment
  }
}

# ── ELASTIC IP ────────────────────────────────────────────────
resource "aws_eip" "tradestack_ip" {
  instance = aws_instance.tradestack_server.id

  tags = {
    Name = "${var.project_name}-eip"
  }
}


# IAM Role for EC2
resource "aws_iam_role" "tradestack_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Allow EC2 to read Secrets Manager
resource "aws_iam_role_policy" "secrets_policy" {
  name = "${var.project_name}-secrets-policy"
  role = aws_iam_role.tradestack_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:us-east-2:169588426254:secret:tradestack/*"
      }
    ]
  })
}

# Instance profile to attach role to EC2
resource "aws_iam_instance_profile" "tradestack_profile" {
  name = "${var.project_name}-profile"
  role = aws_iam_role.tradestack_role.name
}
