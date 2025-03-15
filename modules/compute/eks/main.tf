# modules/compute/eks/main.tf

# Add data sources to find appropriate subnets
data "aws_vpc" "selected" {
  default = true
}

data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnet" "filtered" {
  for_each = toset(data.aws_subnets.available.ids)
  id       = each.value
}

# Filter for subnets in supported AZs - only use those in a, b, c, d, f
locals {
  supported_azs = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  supported_subnets = [
    for subnet_id, subnet in data.aws_subnet.filtered : 
    subnet.id 
    if contains(local.supported_azs, subnet.availability_zone)
  ]
  
  # Ensure we have at least 2 subnets
  selected_subnets = slice(local.supported_subnets, 0, min(length(local.supported_subnets), 2))
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = var.cluster_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
  
  tags = merge(
    var.common_tags,
    {
      Name = var.cluster_role_name
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_cluster_admin_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create EKS cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.32"
  access_config {
      authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids              = local.selected_subnets
    security_group_ids      = var.security_group_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_admin_policy
  ]

  tags = var.common_tags
}

# OIDC Provider for EKS cluster
data "tls_certificate" "eks" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  
  tags = var.common_tags
}

# Import service account module - fix path and parameters
module "service_account" {
  source = "./service_account"
  
  role_name           = var.service_account_role_name
  cluster_name        = var.cluster_name
  cluster_endpoint    = aws_eks_cluster.cluster.endpoint
  cluster_ca_cert     = aws_eks_cluster.cluster.certificate_authority[0].data
  service_account_name = var.service_account_name
  namespace           = var.resource_namespace
  oidc_issuer_url     = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  oidc_thumbprint     = data.tls_certificate.eks.certificates[0].sha1_fingerprint
  
  common_tags         = var.common_tags
}

# Create EKS Node Group using the service account module's role
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = module.service_account.role_arn
  subnet_ids      = local.selected_subnets

  scaling_config {
    desired_size = var.desired_nodes
    min_size     = var.min_nodes
    max_size     = var.max_nodes
  }

  instance_types = [var.node_instance_type]

  tags = var.common_tags
}

# Get the current IAM identity
data "aws_caller_identity" "current" {}

# Create an access entry for your current user/role
resource "aws_eks_access_entry" "current_user" {
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = data.aws_caller_identity.current.arn
  type          = "STANDARD"
}

# Associate the admin policy with your user/role
resource "aws_eks_access_policy_association" "current_user_admin" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_caller_identity.current.arn

  access_scope {
    type = "cluster"
  }
}

module "user" {
  source = "./users"
  
  username            = var.username
  groups              = var.groups
  admin_group_name    = var.admin_group_name
  console_access      = var.console_access
  programmatic_access = var.programmatic_access
  force_destroy       = var.force_destroy
  secret_name         = var.secret_name
  common_tags         = var.common_tags
}

resource "aws_eks_access_entry" "admin_user" {
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = module.user.user_arn
  type          = "STANDARD"

  depends_on = [
    aws_eks_cluster.cluster,
    module.user
  ]
}

resource "aws_eks_access_policy_association" "admin_access" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = module.user.user_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.admin_user
  ]
}