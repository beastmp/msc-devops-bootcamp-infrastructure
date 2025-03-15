# modules/container/ecr/main.tf
# Private rpository code
resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key : null
  }

  tags = merge(
    var.common_tags,
    {
      "Component Role" = var.component_role
      "Name"           = var.repository_name
    }
  )
}

# Public Repo Code
# resource "aws_ecrpublic_repository" "this" {
#   repository_name = var.repository_name

#   # Public repositories use catalog_data instead of encryption/scanning config
#   catalog_data {
#     description       = var.description
#     about_text        = var.about_text
#     usage_text        = var.usage_text
#     operating_systems = var.operating_systems
#     architectures     = var.architectures
#   }

#   tags = merge(
#     var.common_tags,
#     {
#       "Component Role" = var.component_role
#       "Name"           = var.repository_name
#     }
#   )
# }