# modules/storage/s3/outputs.tf
output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket_domain_name
}