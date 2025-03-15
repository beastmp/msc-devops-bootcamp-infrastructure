# modules/compute/ec2/outputs.tf
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.instance.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.instance.arn
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.instance.private_ip
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.instance.public_ip
}

# IAM-related outputs
output "role_name" {
  description = "Name of the IAM role for EC2 instance"
  value       = module.iam.role_name
}

output "role_arn" {
  description = "ARN of the IAM role for EC2 instance"
  value       = module.iam.role_arn
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instance"
  value       = module.iam.instance_profile_name
}

output "instance_profile_arn" {
  description = "ARN of the IAM instance profile for EC2 instance"
  value       = module.iam.instance_profile_arn
}