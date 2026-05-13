variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (Ubuntu 24.04 LTS in us-east-1)"
  type        = string
  default     = "ami-0ec10929233384c7f"
}

variable "instance_type" {
  description = "EC2 instance type; t3.medium is the minimum for a stable Minecraft server"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size in GB; 20 GB covers the OS, Docker, and world data"
  type        = number
  default     = 20
}

variable "key_name" {
  description = "Name of the existing AWS key pair used for SSH access"
  type        = string
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed to SSH into the instance; restrict to your IP in production"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository that stores the Minecraft image"
  type        = string
  default     = "cs312-minecraft"
}

variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name for Minecraft world backups"
  type        = string
  default     = "cs312-minecraft-world-backup"
}

variable "minecraft_image_tag" {
  description = "Image tag to pull from ECR; pin this to a specific version for reproducibility"
  type        = string
  default     = "latest"
}
