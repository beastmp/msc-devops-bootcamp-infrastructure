# modules/pipeline/codepipeline/main.tf

# IAM role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.pipeline_name}-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.pipeline_name}-pipeline-role"
    }
  )
}

# Attach managed policies to CodePipeline role
resource "aws_iam_role_policy_attachment" "codepipeline_admin_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.pipeline_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.pipeline_name}-codebuild-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "codebuild_admin_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# S3 bucket for storing pipeline artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifacts_bucket_name
  force_destroy = true

  tags = merge(
    var.common_tags,
    {
      Name = var.artifacts_bucket_name
    }
  )
}

# Create GitHub connection
resource "aws_codeconnections_connection" "github" {
  name          = var.github_connection_name
  provider_type = "GitHub"

  tags = merge(
    var.common_tags,
    {
      Name = var.github_connection_name
    }
  )
}

locals {
  # Extract registry alias from ECR URL if it's a public repository
  is_public_ecr = can(regex("^public.ecr.aws/", var.ecr_repository_url))
  registry_alias = local.is_public_ecr ? split("/", trimprefix(var.ecr_repository_url, "public.ecr.aws/"))[0] : ""
  
  # Extract AWS account ID and region for private ECR repositories
  aws_account_id = local.is_public_ecr ? "" : split(".", split("/", var.ecr_repository_url)[0])[0]
  ecr_region = local.is_public_ecr ? "us-east-1" : regex("ecr\\.([a-z0-9-]+)\\.amazonaws\\.com", var.ecr_repository_url)[0]
}

# CodeBuild project for building the Docker image
resource "aws_codebuild_project" "build" {
  name          = var.build_project_name
  description   = "Build Docker image for ${var.pipeline_name}"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "15"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspec-build.yml.tftpl", {
      region               = local.ecr_region,
      component_role       = var.component_role
      ecr_repository_url   = var.ecr_repository_url
      eks_cluster_name     = var.eks_cluster_name
      eks_user_secret_name = var.eks_user_secret_name
    })
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.pipeline_name}-build"
    }
  )
}

# CodeBuild project for deployment
resource "aws_codebuild_project" "deploy" {
  name          = var.deploy_project_name
  description   = "Deploy to EKS for ${var.pipeline_name}"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "15"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspec-deploy.yml.tftpl", {
      region               = local.ecr_region,
      component_role       = var.component_role
      eks_cluster_name     = var.eks_cluster_name
      eks_user_secret_name = var.eks_user_secret_name
    })
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.pipeline_name}-deploy"
    }
  )
}

resource "aws_codepipeline" "this" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
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
        ConnectionArn    = aws_codeconnections_connection.github.arn
        FullRepositoryId = var.repository_id
        BranchName       = var.branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployAction"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy.name
      }
    }
  }
}