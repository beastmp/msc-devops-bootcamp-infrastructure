variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
}

variable "service_name" {
  description = "Service name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "github_repository" {
  description = "GitHub repository name (owner/repo)"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to use"
  type        = string
  default     = "main"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for resources"
  type        = string
  default     = "default"
}

variable "dynamodb_tables" {
  description = "DynamoDB table names"
  type = object({
    products = string
    orders   = string
    tickets  = string
  })
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
