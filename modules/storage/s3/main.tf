# modules/storage/s3/main.tf
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = merge(
    var.common_tags,
    {
      Name             = var.bucket_name
      "Component Role" = var.component_role
    }
  )
}

# Enable versioning if specified
resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.versioning_enabled ? 1 : 0
  
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}