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
