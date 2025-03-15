# modules/pipeline/codepipeline/variables.tf
variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
}

variable "component_role" {
  description = "Component role identifier for resource tagging"
  type        = string
}

variable "repository_id" {
  description = "GitHub repository ID (format: username/repo)"
  type        = string
}

variable "branch_name" {
  description = "Branch name to use as source"
  type        = string
  default     = "main"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster to deploy to"
  type        = string
  default     = ""
}

variable "eks_user_secret_name" {
  description = "The name of the AWS Secrets Manager secret containing the EKS user credentials"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket for pipeline artifacts"
  type        = string
  default     = null  # Will use default naming if not provided
}

variable "github_connection_name" {
  description = "Name of the GitHub CodeStar connection"
  type        = string
  default     = null
}

variable "build_project_name" {
  description = "Name of the CodeBuild project for build stage"
  type        = string
  default     = null
}

variable "deploy_project_name" {
  description = "Name of the CodeBuild project for deploy stage"
  type        = string
  default     = null
}

# Common variables
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}