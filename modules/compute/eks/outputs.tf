# modules/compute/eks/outputs.tf
output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.cluster.id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.cluster.name
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.cluster.arn
}

output "cluster_endpoint" {
  description = "The endpoint URL for the EKS cluster"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "The CA certificate for the EKS cluster"
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "The security group ID of the EKS cluster"
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "node_group_id" {
  description = "The ID of the EKS node group"
  value       = aws_eks_node_group.node_group.id
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.node_group.arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.node_group.status
}

output "node_group_resources" {
  description = "List of objects containing information about underlying resources"
  value       = aws_eks_node_group.node_group.resources
}

output "cluster_role_arn" {
  description = "ARN of IAM role for EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

# Service account and node role outputs (from service_account module)
output "service_account_role_name" {
  description = "The name of the IAM role for the service account"
  value       = module.service_account.role_name
}

output "service_account_role_arn" {
  description = "The ARN of the IAM role for the service account"
  value       = module.service_account.role_arn
}

output "node_role_arn" {
  description = "ARN of IAM role for EKS node group (same as service account role)"
  value       = module.service_account.role_arn
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "The URL of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.url
}

# User outputs
output "user_name" {
  description = "Name of the created IAM user"
  value       = module.user.user_name
}

output "user_arn" {
  description = "ARN of the created IAM user"
  value       = module.user.user_arn
}

output "user_access_key_id" {
  description = "Access key ID of created user"
  value       = module.user.access_key_id
  sensitive   = true
}

output "user_secret_key" {
  description = "Secret access key of created user"
  value       = module.user.secret_key
  sensitive   = true
}

output "user_encrypted_password" {
  description = "Encrypted password for console access"
  value       = module.user.encrypted_password
  sensitive   = true
}

output "user_is_admin" {
  description = "Whether the user has admin privileges"
  value       = module.user.is_admin
}

output "user_secret_id" {
  description = "Secret ID for user credentials in Secrets Manager"
  value       = module.user.user_secret_id
}

output "user_secret_arn" {
  description = "Secret ARN for user credentials in Secrets Manager"
  value       = module.user.user_secret_arn
}

output "user_secret_name" {
  description = "The name of the secret storing user credentials"
  value       = module.user.user_secret_name
}