# modules/compute/eks/service_account/main.tf
resource "aws_iam_role" "service_account" {
  name = var.role_name
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.oidc_issuer_url, "https://", "")}"
        },
        Condition = {
          StringEquals = {
            "${replace(var.oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name            = var.role_name
      EKSCluster      = var.cluster_name
      ServiceAccount  = var.service_account_name
      Namespace       = var.namespace
    }
  )
}

# Get current account ID
data "aws_caller_identity" "current" {}

# Attach policies to the service account role
resource "aws_iam_role_policy_attachment" "service_account_admin_policy" {
  role       = aws_iam_role.service_account.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.service_account.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.service_account.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read" {
  role       = aws_iam_role.service_account.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "dynamo_db_full_access" {
  role       = aws_iam_role.service_account.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}