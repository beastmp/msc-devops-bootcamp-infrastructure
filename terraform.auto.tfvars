# Organization and naming
org_name       = "beastmpdevelopment"
team_id        = "devops-bootcamp"
service_name   = "cloudmart"

# Security Group configurations
security_group_configs = {
  "default" = {
    component_role = "default"
    description = "Default security group"
    ingress_rules = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH access"
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP access"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS access"
      },
      {
        from_port   = 5001
        to_port     = 5001
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP access"
      }
    ]
  }
}

# DynamoDB Table configurations
dynamodb_configs = {
  "products" = {
    component_role = "products"
    hash_key       = "id"
    attributes     = [
      {
        name = "id"
        type = "S"
      }
    ]
  },
  "orders" = {
    component_role = "orders"
    hash_key       = "id"
    attributes     = [
      {
        name = "id"
        type = "S"
      }
    ]
  },
  "tickets" = {
    component_role = "tickets"
    hash_key       = "id"
    attributes     = [
      {
        name = "id"
        type = "S"
      }
    ]
  }
}

# EKS Configuration
eks_configs = {
  "main" = {
    component_role     = "main"
    node_instance_type = "t3.medium"
    desired_nodes      = 1
    service_account = {
      namespace        = "default"
    }
    user = {
      console_access      = true
      programmatic_access = true
      force_destroy       = true
    }
  }
}

ecr_configs = {
  "backend" = {
    component_role = "backend"
    force_delete   = true
  },
  "frontend" = {
    component_role = "frontend"
    force_delete   = true
  }
}

# CI/CD Pipeline configurations
pipeline_configs = {
  "frontend" = {
    component_role     = "frontend"
    repository_id      = "beastmp/msc-devops-bootcamp-frontend"
    branch_name        = "main"
    ecr_repository_key = "frontend"
    eks_cluster_key    = "main"
  },
  "backend" = {
    component_role     = "backend"
    repository_id      = "beastmp/msc-devops-bootcamp-backend"
    branch_name        = "main"
    ecr_repository_key = "backend"
    eks_cluster_key    = "main"
  }
}