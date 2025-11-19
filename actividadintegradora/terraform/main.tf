terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Obtener la VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Obtener las subredes por defecto
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Crear un Security Group para la instancia
resource "aws_security_group" "todoing_sg" {
  name        = "todoing-security-group"
  description = "Security group for ToDoing application"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto 8080 para la aplicación
  ingress {
    description = "Application Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB (solo para acceso interno si es necesario)
  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo el tráfico de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "todoing-sg"
    Environment = var.environment
    Project     = "ToDoing"
  }
}

# Obtener la AMI más reciente de Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair para SSH
resource "aws_key_pair" "todoing_key" {
  key_name   = "todoing-key"
  public_key = file(var.public_key_path)

  tags = {
    Name        = "todoing-key"
    Environment = var.environment
  }
}

# Instancia EC2
resource "aws_instance" "todoing_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.todoing_key.key_name
  vpc_security_group_ids      = [aws_security_group.todoing_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y python3 python3-pip
              EOF

  tags = {
    Name        = "todoing-server"
    Environment = var.environment
    Project     = "ToDoing"
    ManagedBy   = "Terraform"
  }
}

# Crear archivo de inventario de Ansible dinámicamente
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory.tpl", {
    server_ip   = aws_instance.todoing_server.public_ip
    ssh_user    = "ubuntu"
    private_key = var.private_key_path
  })

  filename = "${path.module}/inventory.ini"

  depends_on = [aws_instance.todoing_server]
}

# Outputs
output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.todoing_server.id
}

output "instance_public_ip" {
  description = "IP pública de la instancia"
  value       = aws_instance.todoing_server.public_ip
}

output "instance_public_dns" {
  description = "DNS público de la instancia"
  value       = aws_instance.todoing_server.public_dns
}

output "ssh_connection" {
  description = "Comando SSH para conectarse"
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.todoing_server.public_ip}"
}

output "application_url" {
  description = "URL de la aplicación"
  value       = "http://${aws_instance.todoing_server.public_ip}:8080"
}