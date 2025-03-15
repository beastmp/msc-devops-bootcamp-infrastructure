# modules/compute/eks/users/outputs.tf
output "user_name" {
  description = "Name of the created IAM user"
  value       = aws_iam_user.user.name
}

output "user_arn" {
  description = "ARN of the created IAM user"
  value       = aws_iam_user.user.arn
}

output "access_key_id" {
  description = "Access key ID of created user"
  value       = var.programmatic_access ? aws_iam_access_key.user_key[0].id : null
  sensitive   = true
}

output "secret_key" {
  description = "Secret access key of created user"
  value       = var.programmatic_access ? aws_iam_access_key.user_key[0].secret : null
  sensitive   = true
}

output "encrypted_password" {
  description = "Encrypted password for console access"
  value       = var.console_access ? aws_iam_user_login_profile.user_console[0].encrypted_password : null
  sensitive   = true
}

output "is_admin" {
  description = "Whether this user has admin privileges"
  value       = contains(var.groups, var.admin_group_name)
}

output "user_secret_id" {
  description = "Secret ID for user credentials in Secrets Manager"
  value       = aws_secretsmanager_secret.user_credentials.id
}

output "user_secret_arn" {
  description = "Secret ARN for user credentials in Secrets Manager"
  value       = aws_secretsmanager_secret.user_credentials.arn
}

output "user_secret_name" {
  description = "Secret name for user credentials in Secrets Manager"
  value       = aws_secretsmanager_secret.user_credentials.name
}