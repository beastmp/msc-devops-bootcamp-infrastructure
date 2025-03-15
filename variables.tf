# AWS Provider Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1" # Default region
}

# Organization and naming
variable "org_name" {
  description = "Organization name for resource naming"
  type        = string
}

variable "team_id" {
  description = "Team identifier for resource naming"
  type        = string
}

variable "service_name" {
  description = "Service name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "ami_mappings" {
  description = "AMI mappings by platform and component role"
  type = map(object({
    owners  = list(string)
    filters = map(list(string))
  }))
  default = {
    "linux" = {
      owners = ["amazon"]
      filters = {
        name                = ["amzn2-ami-hvm-*-x86_64-gp2"]
        virtualization-type = ["hvm"]
      }
    },
    "windows" = {
      owners = ["801119661308"] # Amazon
      filters = {
        name                = ["Windows_Server-2022-English-Full-Base-*"]
        virtualization-type = ["hvm"]
      }
    }
  }
}

# Instance configurations
variable "ec2_configs" {
  description = "Map of EC2 instance configurations"
  type = map(object({
    instance_type      = optional(string, "t2.micro")
    component_role     = string
    platform           = string
    user_data          = optional(string, "")
    root_volume_size   = optional(number, 30)
    root_volume_type   = optional(string, "gp2")
    basic_permission_actions = optional(list(string), [])
  }))
  default = {}
}

# EKS Configurations
variable "eks_configs" {
  description = "Configuration for EKS clusters"
  type = map(object({
    cluster_name            = optional(string)
    node_instance_type      = optional(string, "t3.medium")
    desired_nodes           = optional(number, 2)
    resource_namespace      = optional(string, "default")
    component_role          = string
    
    service_account = optional(object({
      namespace        = optional(string, "default")
    }), {})
    
    user = optional(object({
      groups               = optional(list(string), ["Administrators"])
      admin_group_name     = optional(string, "Administrators")
      console_access       = optional(bool, true)
      programmatic_access  = optional(bool, true)
      force_destroy        = optional(bool, true)
    }), {})
  }))
  default = {}
}

# S3 bucket configurations
variable "s3_configs" {
  description = "Map of S3 bucket configurations"
  type = map(object({
    component_role     = string
    versioning_enabled = optional(bool, false)
  }))
  default = {}
}

# DynamoDB Table configurations
variable "dynamodb_configs" {
  description = "Map of DynamoDB table configurations"
  type = map(object({
    component_role  = string
    billing_mode    = optional(string, "PAY_PER_REQUEST")
    hash_key        = optional(string, "id")
    attributes      = optional(list(object({
      name = string
      type = string
    })), [{ name = "id", type = "S" }])
  }))
  default = {}
}

#ECR Repository configurations
variable "ecr_configs" {
  description = "Map of ECR repository configurations"
  type = map(object({
    repository_name   = optional(string)
    component_role    = string
    mutability        = optional(string, "MUTABLE")
    scan_on_push      = optional(bool, true)
    force_delete      = optional(bool, false)
    encryption_type   = optional(string, "AES256")
  }))
  default = {}
}

# CodePipeline configurations
variable "pipeline_configs" {
  description = "Map of CodePipeline configurations"
  type = map(object({
    component_role       = string
    repository_id        = string
    branch_name          = optional(string, "main")
    ecr_repository_key   = string
    eks_cluster_key      = string
  }))
  default = {}
}

# Security Group configurations
variable "security_group_configs" {
  description = "Map of security group configurations"
  type = map(object({
    name           = optional(string)
    description    = optional(string, "Managed by Terraform")
    component_role = string
    vpc_id         = optional(string, null)
    ingress_rules  = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = optional(string, null)
    })), [])
    egress_rules  = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = optional(string, null)
    })), [{
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }])
  }))
  default = {}
}