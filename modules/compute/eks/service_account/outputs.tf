# modules/compute/eks/service_account/outputs.tf
output "role_name" {
  description = "Name of the IAM role for service account"
  value       = aws_iam_role.service_account.name
}

output "role_arn" {
  description = "ARN of the IAM role for service account"
  value       = aws_iam_role.service_account.arn
}

output "role_id" {
  description = "ID of the IAM role for service account"
  value       = aws_iam_role.service_account.id
}