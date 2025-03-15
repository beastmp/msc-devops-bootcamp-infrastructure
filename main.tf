# ----------------------------------------------------------
# Provider Configuration
# ----------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {}

locals {
  eks_clusters = var.eks_configs
}

# ----------------------------------------------------------
# Local Variables
# ----------------------------------------------------------
locals {
  common_tags = {
    Organization = var.org_name
    Team         = var.team_id
    Service      = var.service_name
    Environment  = var.environment
    ManagedBy    = "terraform"
  }

  # Clean name components for consistent naming
  clean = {
    org     = lower(replace(replace(var.org_name, " ", "-"), "_", "-"))
    team    = lower(replace(replace(var.team_id, " ", "-"), "_", "-"))
    service = lower(replace(replace(var.service_name, " ", "-"), "_", "-"))
    env     = lower(replace(replace(var.environment, " ", "-"), "_", "-"))
  }

  # Naming formats
  levels = {
    service = "${local.clean.service}-${local.clean.env}"
    team    = "${local.clean.team}-${local.clean.service}-${local.clean.env}"
    org     = "${local.clean.org}-${local.clean.team}-${local.clean.service}-${local.clean.env}"
  }

  formats = {
    component_role = "${local.levels.service}-%s-%s-%s"    # format-module-component_role-component
    platform       = "${local.levels.service}-%s-%s-%s-%s" # format-module-component_role-platform-component
    github         = "${local.levels.service}-%s-%s"       # For github connections
  }

  module_keys = {
    s3        = "s3"
    ec2       = "ec2"
    eks       = "eks"
    ecr       = "ecr"
    dynamodb  = "ddb"
    pipeline  = "pipe"
    security  = "sec"
  }

  # Component keys for naming
  component_keys = {
    instance        = "instance"
    volume          = "volume"
    instance_role   = "role-instance"
    cluster_role    = "role-cluster"
    sa_role         = "role-sa"
    profile         = "profile"
    policy          = "policy"
    secret          = "secret"
    key             = "key"
    cluster         = "cluster"
    node_group      = "group-node"
    service_account = "sa"
    bucket          = "bucket"
    table           = "table"
    repository      = "repo"
    pipeline        = "pipeline"
    build           = "build"
    deploy          = "deploy"
    user            = "user"
    security_group  = "group-security"
    artifact        = "artifact"
    connection      = "connection"
  }

}
# ----------------------------------------------------------
# Data Sources
# ----------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "selected" {
  for_each = var.ec2_configs
  
  most_recent = true
  owners      = try(var.ami_mappings[each.value.platform].owners, ["amazon"])
  
  dynamic "filter" {
    for_each = try(var.ami_mappings[each.value.platform].filters, {})
    content {
      name   = filter.key
      values = filter.value
    }
  }
}

locals {
  subnet_map = {
    for i, id in data.aws_subnets.default.ids : "subnet${i}" => id
  }
}

# ----------------------------------------------------------
# Modules
# ----------------------------------------------------------

module "security_groups" {
  source   = "./modules/security/securitygroups"
  for_each = var.security_group_configs
  
  name           = format(local.formats.component_role, local.module_keys.security, each.value.component_role, local.component_keys.security_group)
  description    = each.value.description
  vpc_id         = data.aws_vpc.default.id
  ingress_rules  = each.value.ingress_rules
  egress_rules   = each.value.egress_rules
  common_tags    = merge(local.common_tags, { Component = each.value.component_role })
}

module "s3_buckets" {
  source   = "./modules/storage/s3"
  for_each = var.s3_configs
  
  bucket_name        = format(local.formats.component_role, local.module_keys.s3, each.value.component_role, local.component_keys.bucket)
  component_role     = each.value.component_role
  versioning_enabled = each.value.versioning_enabled
  common_tags        = merge(local.common_tags, { Component = each.value.component_role })
}

module "dynamodb_tables" {
  source   = "./modules/storage/dynamodb"
  for_each = var.dynamodb_configs
  
  table_name      = format(local.formats.component_role, local.module_keys.dynamodb, each.value.component_role, local.component_keys.table)
  component_role  = each.value.component_role
  billing_mode    = each.value.billing_mode
  hash_key        = each.value.hash_key
  attributes      = each.value.attributes
  common_tags     = merge(local.common_tags, { Component = each.value.component_role })
}

module "ec2_instances" {
  source   = "./modules/compute/ec2"
  for_each = var.ec2_configs

  name                  = format(local.formats.platform, local.module_keys.ec2, each.value.component_role, each.value.platform, local.component_keys.instance)
  ami_id                = data.aws_ami.selected[each.key].id
  instance_type         = each.value.instance_type
  key_name              = format(local.formats.platform, local.module_keys.ec2, each.value.component_role, each.value.platform, local.component_keys.key)
  user_data             = each.value.user_data != "" ? file(each.value.user_data) : ""
  root_volume_name      = format(local.formats.platform, local.module_keys.ec2, each.value.component_role, each.value.platform, local.component_keys.volume)
  root_volume_size      = each.value.root_volume_size
  root_volume_type      = each.value.root_volume_type
  subnet_id             = tolist(data.aws_subnets.default.ids)[0]
  vpc_id                = data.aws_vpc.default.id
  security_group_ids    = [module.security_groups["default"].security_group_id]
  component_role        = each.value.component_role
  platform              = each.value.platform
  secret_name           = format(local.formats.platform, local.module_keys.ec2, each.value.component_role, each.value.platform, local.component_keys.secret)
  
  # IAM options
  instance_role_name       = format(local.formats.platform, local.module_keys.ec2, each.value.component_role, each.value.platform, local.component_keys.instance_role)
  instance_profile_name    = format(local.formats.platform, local.module_keys.ec2, each.value.component_role, each.value.platform, local.component_keys.profile)
  instance_policy_name     = format(local.formats.platform, local.module_keys.ec2, each.value.component_role, each.value.platform, local.component_keys.policy)
  service_principal        = "ec2.amazonaws.com"
  basic_permission_actions = each.value.basic_permission_actions
  
  common_tags = merge(local.common_tags, { Component = each.value.component_role })
}

locals {
  # Create a map of component_role -> table_name
  tables_by_role = {
    for key, config in var.dynamodb_configs : 
      config.component_role => module.dynamodb_tables[key].table_name
  }
}

module "eks" {
  source   = "./modules/compute/eks"
  for_each = var.eks_configs

  # EKS cluster configuration
  cluster_name       = format(local.formats.component_role, local.module_keys.eks, each.value.component_role, local.component_keys.cluster)
  cluster_role_name  = format(local.formats.component_role, local.module_keys.eks, each.value.component_role, local.component_keys.cluster_role)
  node_group_name    = format(local.formats.component_role, local.module_keys.eks, each.value.component_role, local.component_keys.node_group)
  node_instance_type = each.value.node_instance_type
  resource_namespace = each.value.resource_namespace
  
  # Node scaling configuration
  desired_nodes      = each.value.desired_nodes
  min_nodes          = 1
  max_nodes          = 3
  
  # Network configuration
  subnet_ids         = data.aws_subnets.default.ids
  security_group_ids = [module.security_groups["default"].security_group_id]

  # DynamoDB table information
  dynamodb_tables = {
    products = local.tables_by_role["products"]
    orders   = local.tables_by_role["orders"]
    tickets  = local.tables_by_role["tickets"]
  }
  
  # IRSA configuration
  service_account_name        = format(local.formats.component_role, local.module_keys.eks, each.value.component_role, local.component_keys.service_account)
  service_account_role_name   = format(local.formats.component_role, local.module_keys.eks, each.value.component_role, local.component_keys.sa_role)
  
  # User configuration
  username            = format(local.formats.component_role, local.module_keys.eks, "admin", local.component_keys.user)
  groups              = each.value.user.groups
  admin_group_name    = each.value.user.admin_group_name
  console_access      = each.value.user.console_access
  programmatic_access = each.value.user.programmatic_access
  force_destroy       = each.value.user.force_destroy
  secret_name         = format(local.formats.component_role, local.module_keys.eks, "admin", local.component_keys.secret)

  common_tags         = merge(local.common_tags, { Component = each.value.component_role })
}

module "ecr_repositories" {
  source   = "./modules/container/ecr"
  for_each = var.ecr_configs
  
  repository_name   = format(local.formats.component_role, local.module_keys.ecr, each.value.component_role, local.component_keys.repository)
  component_role    = each.value.component_role

  # Private repos
  mutability      = each.value.mutability
  scan_on_push    = each.value.scan_on_push
  encryption_type = each.value.encryption_type
  force_delete      = each.value.force_delete

  common_tags       = merge(local.common_tags, { Component = each.value.component_role })

  depends_on = [module.eks]
}

module "pipelines" {
  source   = "./modules/pipeline/codepipeline"
  for_each = var.pipeline_configs
  
  pipeline_name        = format(local.formats.component_role, local.module_keys.pipeline, each.value.component_role, local.component_keys.pipeline)
  component_role         = each.value.component_role
  repository_id        = each.value.repository_id
  branch_name          = each.value.branch_name
  
  ecr_repository_name  = module.ecr_repositories[each.value.ecr_repository_key].repository_name
  ecr_repository_url   = module.ecr_repositories[each.value.ecr_repository_key].repository_url

  eks_cluster_name     = module.eks[each.value.eks_cluster_key].cluster_name
  eks_user_secret_name = module.eks[each.value.eks_cluster_key].user_secret_name  

  artifacts_bucket_name  = format(local.formats.component_role, local.module_keys.pipeline, each.value.component_role, local.component_keys.artifact)
  github_connection_name = format(local.formats.github, each.value.component_role, "github")
  build_project_name     = format(local.formats.platform, local.module_keys.pipeline, each.value.component_role, "project", local.component_keys.build)
  deploy_project_name    = format(local.formats.platform, local.module_keys.pipeline, each.value.component_role, "project", local.component_keys.deploy)
  
  common_tags = merge(local.common_tags, { Component = each.value.component_role })

  depends_on = [
    module.eks,
    module.ecr_repositories
  ]
}