# Security Group Outputs
output "security_group_ids" {
  description = "Map of security group keys to their IDs"
  value = {
    for key, sg in module.security_groups : key => sg.security_group_id
  }
}

output "security_group_arns" {
  description = "Map of security group keys to their ARNs"
  value = {
    for key, sg in module.security_groups : key => sg.security_group_arn
  }
}

output "security_group_names" {
  description = "Map of security group keys to their names"
  value = {
    for key, sg in module.security_groups : key => sg.security_group_name
  }
}

# S3 Bucket Outputs
output "s3_bucket_ids" {
  description = "Map of S3 bucket keys to their IDs"
  value = {
    for key, bucket in module.s3_buckets : key => bucket.bucket_id
  }
}

output "s3_bucket_arns" {
  description = "Map of S3 bucket keys to their ARNs"
  value = {
    for key, bucket in module.s3_buckets : key => bucket.bucket_arn
  }
}

output "s3_bucket_names" {
  description = "Map of S3 bucket keys to their names"
  value = {
    for key, bucket in module.s3_buckets : key => bucket.bucket_name
  }
}

output "s3_bucket_domain_names" {
  description = "Map of S3 bucket keys to their domain names"
  value = {
    for key, bucket in module.s3_buckets : key => bucket.bucket_domain_name
  }
}

# DynamoDB Table Outputs
output "dynamodb_table_names" {
  description = "Map of DynamoDB table keys to their names"
  value = {
    for key, table in module.dynamodb_tables : key => table.table_name
  }
}

output "dynamodb_table_arns" {
  description = "Map of DynamoDB table keys to their ARNs"
  value = {
    for key, table in module.dynamodb_tables : key => table.table_arn
  }
}

output "dynamodb_table_ids" {
  description = "Map of DynamoDB table keys to their IDs"
  value = {
    for key, table in module.dynamodb_tables : key => table.table_id
  }
}

# EC2 Outputs
output "ec2_instance_ids" {
  description = "Map of EC2 instance names to IDs"
  value = {
    for key, instance in module.ec2_instances : key => instance.instance_id
  }
}

output "ec2_instance_arns" {
  description = "Map of EC2 instance names to ARNs"
  value = {
    for key, instance in module.ec2_instances : key => instance.instance_arn
  }
}

output "ec2_private_ips" {
  description = "Map of EC2 instance names to private IPs"
  value = {
    for key, instance in module.ec2_instances : key => instance.instance_private_ip
  }
}

output "ec2_public_ips" {
  description = "Map of EC2 instance names to public IPs (if available)"
  value = {
    for key, instance in module.ec2_instances : key => instance.instance_public_ip if instance.instance_public_ip != null
  }
}

# EKS Cluster Outputs
output "eks_cluster_ids" {
  description = "Map of EKS cluster keys to their IDs"
  value = length(var.eks_configs) > 0 ? {
    for key, eks in module.eks : key => eks.cluster_id
  } : {}
}

output "eks_cluster_arns" {
  description = "Map of EKS cluster keys to their ARNs"
  value = length(var.eks_configs) > 0 ? {
    for key, eks in module.eks : key => eks.cluster_arn
  } : {}
}

output "eks_cluster_endpoints" {
  description = "Map of EKS cluster keys to their endpoints"
  value = length(var.eks_configs) > 0 ? {
    for key, eks in module.eks : key => eks.cluster_endpoint
  } : {}
}

output "eks_cluster_security_group_ids" {
  description = "Map of EKS cluster keys to their security group IDs"
  value = length(var.eks_configs) > 0 ? {
    for key, eks in module.eks : key => eks.cluster_security_group_id
  } : {}
}

output "eks_node_group_ids" {
  description = "Map of EKS cluster keys to their node group IDs"
  value = length(var.eks_configs) > 0 ? {
    for key, eks in module.eks : key => eks.node_group_id
  } : {}
}

# Add new outputs for IRSA integration
output "eks_oidc_provider_url" {
  description = "The URL of the EKS OIDC Provider"
  value = length(var.eks_configs) > 0 ? {
    for key, eks in module.eks : key => eks.oidc_provider_url
  } : {}
}

output "eks_service_account_role_arn" {
  description = "ARN of the IAM role for Kubernetes service account"
  value = length(var.eks_configs) > 0 ? {
    for key, eks in module.eks : key => eks.service_account_role_arn
  } : {}
}

output "eks_service_account_role_name" {
  description = "Name of the IAM role for Kubernetes service account"
  value = length(var.eks_configs) > 0 ? {
    for key, eks in module.eks : key => eks.service_account_role_name
  } : {}
}

output "eks_cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value = length(var.eks_configs) > 0 ? {
    for key, eks in module.eks : key => eks.cluster_ca_certificate
  } : {}
  sensitive = true
}

# Additional outputs for Kubernetes configuration
output "dynamodb_tables_for_kubernetes" {
  description = "DynamoDB table names for Kubernetes configuration"
  value = {
    products = module.dynamodb_tables["products"].table_name
    orders = module.dynamodb_tables["orders"].table_name
    tickets = module.dynamodb_tables["tickets"].table_name
  }
}

# ECR Repository Outputs
output "ecr_repository_arns" {
  description = "Map of ECR repository names to their ARNs"
  value = {
    for key, repo in module.ecr_repositories : key => repo.repository_arn
  }
}

output "ecr_repository_urls" {
  description = "Map of ECR repository names to their URLs"
  value = {
    for key, repo in module.ecr_repositories : key => repo.repository_url
  }
}

output "ecr_repository_names" {
  description = "Map of ECR repository keys to their names"
  value = {
    for key, repo in module.ecr_repositories : key => repo.repository_name
  }
}

output "ecr_registry_ids" {
  description = "Map of ECR repository keys to their registry IDs"
  value = {
    for key, repo in module.ecr_repositories : key => repo.registry_id
  }
}

# CodePipeline Outputs
output "pipeline_ids" {
  description = "Map of pipeline keys to their IDs"
  value = {
    for key, pipeline in module.pipelines : key => pipeline.pipeline_id
  }
}

output "pipeline_arns" {
  description = "Map of pipeline keys to their ARNs"
  value = {
    for key, pipeline in module.pipelines : key => pipeline.pipeline_arn
  }
}

output "pipeline_artifacts_bucket_names" {
  description = "Map of pipeline keys to their artifact bucket names"
  value = {
    for key, pipeline in module.pipelines : key => pipeline.artifacts_bucket_name
  }
}

output "github_connection_arns" {
  description = "Map of pipeline keys to their GitHub connection ARNs"
  value = {
    for key, pipeline in module.pipelines : key => pipeline.github_connection_arn
  }
}

output "github_connection_statuses" {
  description = "Map of pipeline keys to their GitHub connection statuses"
  value = {
    for key, pipeline in module.pipelines : key => pipeline.github_connection_status
  }
}