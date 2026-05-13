terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "cs312" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "cs312-vpc" }
}

resource "aws_subnet" "cs312_public" {
  vpc_id                  = aws_vpc.cs312.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = { Name = "cs312-public-subnet" }
}

resource "aws_internet_gateway" "cs312_igw" {
  vpc_id = aws_vpc.cs312.id
  tags   = { Name = "cs312-igw" }
}

resource "aws_route_table" "cs312_public_rt" {
  vpc_id = aws_vpc.cs312.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cs312_igw.id
  }
  tags = { Name = "cs312-public-rt" }
}

resource "aws_route_table_association" "cs312_public_rta" {
  subnet_id      = aws_subnet.cs312_public.id
  route_table_id = aws_route_table.cs312_public_rt.id
}

# Single security group for the Minecraft server
resource "aws_security_group" "minecraft" {
  name        = "cs312-minecraft-sg"
  description = "Minecraft server: SSH for admin, TCP 25565 for clients"
  vpc_id      = aws_vpc.cs312.id

  ingress {
    description = "SSH admin access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  ingress {
    description = "Minecraft clients"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "cs312-minecraft-sg" }
}

# Minecraft server instance
resource "aws_instance" "minecraft" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.cs312_public.id
  vpc_security_group_ids = [aws_security_group.minecraft.id]
  iam_instance_profile   = "LabInstanceProfile"

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }

  tags = { Name = "cs312-minecraft-server" }
}

# ECR repository for the Minecraft image
resource "aws_ecr_repository" "minecraft" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = var.ecr_repo_name }
}

# S3 bucket for world backups
resource "aws_s3_bucket" "world_backup" {
  bucket        = var.s3_bucket_name
  force_destroy = true
  tags          = { Name = var.s3_bucket_name }
}

resource "aws_s3_bucket_versioning" "world_backup" {
  bucket = aws_s3_bucket.world_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Run Ansible automatically after instance is ready
# resource "null_resource" "ansible_provision" {
#  depends_on = [aws_instance.minecraft]
#
#  triggers = {
#    instance_id = aws_instance.minecraft.id
#  }
#
#  provisioner "local-exec" {
#    command = <<EOT
#      sleep 30 && \
#      ansible-playbook -i "${aws_instance.minecraft.public_ip}," \
#        --private-key ~/.ssh/${var.key_name}.pem \
#        -u ubuntu \
#        -e "ecr_repo_url=${aws_ecr_repository.minecraft.repository_url}" \
#        -e "image_tag=${var.minecraft_image_tag}" \
#        -e "s3_bucket=${aws_s3_bucket.world_backup.bucket}" \
#        -e "aws_region=${var.aws_region}" \
#        ../ansible/playbook.yml
#    EOT
#  }
#}
