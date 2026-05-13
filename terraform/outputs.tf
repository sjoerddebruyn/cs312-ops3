output "minecraft_public_ip" {
  description = "Public IP of the Minecraft server; use this for nmap and to connect in-game"
  value       = aws_instance.minecraft.public_ip
}

output "minecraft_public_dns" {
  description = "Public DNS hostname of the Minecraft server"
  value       = aws_instance.minecraft.public_dns
}

output "ecr_repository_url" {
  description = "ECR repository URL; used in GitHub Actions to push and in Ansible to pull"
  value       = aws_ecr_repository.minecraft.repository_url
}

output "s3_bucket_name" {
  description = "S3 bucket name for world backups"
  value       = aws_s3_bucket.world_backup.bucket
}

output "vpc_id" {
  description = "ID of the provisioned VPC"
  value       = aws_vpc.cs312.id
}

output "ansible_inventory_line" {
  description = "Ready-to-use inventory line for Ansible if running the playbook manually"
  value       = "minecraft ansible_host=${aws_instance.minecraft.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem"
}
