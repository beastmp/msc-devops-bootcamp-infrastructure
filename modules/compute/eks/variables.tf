# modules/compute/eks/variables.tf
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_role_name" {
  description = "Name for the EKS cluster IAM role"
  type        = string
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS node group"
  type        = string
}

variable "desired_nodes" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_nodes" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_nodes" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster and node group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS node group"
  type        = list(string)
}

# Service account parameters
variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
}

variable "dynamodb_tables" {
  description = "Names of DynamoDB tables used by the application"
  type = object({
    products = string
    orders = string
    tickets = string
  })
}

variable "resource_namespace" {
  description = "Namespace for Kubernetes resources"
  type        = string
  default     = "default"
}

variable "service_account_role_name" {
  description = "Name of the IAM role for the service account"
  type        = string
}

# User management
variable "username" {
  description = "Username for the IAM user"
  type        = string
}

variable "groups" {
  description = "List of IAM groups to add the user to"
  type        = list(string)
}

variable "admin_group_name" {
  description = "Name of the administrators group"
  type        = string
  default     = "Administrators"
}

variable "console_access" {
  description = "Whether to create console access for the user"
  type        = bool
  default     = true
}

variable "programmatic_access" {
  description = "Whether to create an access key for the user"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Whether to force destroy the user even if it has non-Terraform resources"
  type        = bool
  default     = true
}

variable "secret_name" {
  description = "Name of the secret in AWS Secrets Manager"
  type        = string
}

# Common variables
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}