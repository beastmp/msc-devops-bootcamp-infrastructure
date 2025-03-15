resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.service_name}-${var.environment}-kubernetes-artifacts"
  force_destroy = true
  
  tags = var.common_tags
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.service_name}-${var.environment}-kubernetes-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.service_name}-${var.environment}-kubernetes-pipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.codepipeline_bucket.arn,
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ],
        Effect = "Allow"
      },
      {
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = aws_codestarconnections_connection.github.arn,
        Effect = "Allow"
      },
      {
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        Resource = "*",
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_codestarconnections_connection" "github" {
  name          = "${var.service_name}-${var.environment}-kubernetes-github"
  provider_type = "GitHub"
  
  tags = var.common_tags
}

resource "aws_codebuild_project" "kubernetes_deploy" {
  name          = "${var.service_name}-${var.environment}-kubernetes-deploy"
  description   = "CodeBuild project for Kubernetes infrastructure"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "20"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }
    
    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.eks_cluster_name
    }
    
    environment_variable {
      name  = "KUBERNETES_NAMESPACE"
      value = var.kubernetes_namespace
    }
    
    # Environment variables for DynamoDB tables
    environment_variable {
      name  = "DYNAMODB_PRODUCTS_TABLE"
      value = var.dynamodb_tables.products
    }
    
    environment_variable {
      name  = "DYNAMODB_ORDERS_TABLE"
      value = var.dynamodb_tables.orders
    }
    
    environment_variable {
      name  = "DYNAMODB_TICKETS_TABLE"
      value = var.dynamodb_tables.tickets
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${path.module}/buildspec.yml"
  }
  
  tags = var.common_tags
}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.service_name}-${var.environment}-kubernetes-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.service_name}-${var.environment}-kubernetes-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*",
        Effect = "Allow"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.codepipeline_bucket.arn,
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ],
        Effect = "Allow"
      },
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:UpdateClusterConfig",
          "eks:DescribeUpdate"
        ],
        Resource = "*",
        Effect = "Allow"
      },
      {
        Action = [
          "dynamodb:*"
        ],
        Resource = "*",
        Effect = "Allow"
      },
      {
        Action = [
          "ssm:GetParameters"
        ],
        Resource = "*",
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_codepipeline" "kubernetes_pipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.github_repository
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployKubernetes"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.kubernetes_deploy.name
      }
    }
  }
  
  tags = var.common_tags
}
