# modules/pipeline/codepipeline/outputs.tf
output "pipeline_id" {
  description = "ID of the CodePipeline"
  value       = aws_codepipeline.this.id
}

output "pipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.this.arn
}

output "artifacts_bucket_name" {
  description = "S3 bucket name used for storing artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "github_connection_arn" {
  description = "GitHub connection ARN"
  value       = aws_codeconnections_connection.github.arn
}

output "github_connection_status" {
  description = "GitHub connection status"
  value       = aws_codeconnections_connection.github.connection_status
}