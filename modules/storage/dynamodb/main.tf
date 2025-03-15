# modules/storage/dynamodb/main.tf
resource "aws_dynamodb_table" "table" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  
  # Define attributes
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name             = var.table_name
      "Component Role" = var.component_role
    }
  )
}