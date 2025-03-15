output "pipeline_id" {
  description = "ID of the Kubernetes deployment pipeline"
  value       = aws_codepipeline.kubernetes_pipeline.id
}

output "pipeline_arn" {
  description = "ARN of the Kubernetes deployment pipeline"
  value       = aws_codepipeline.kubernetes_pipeline.arn
}

output "github_connection_arn" {
  description = "ARN of the GitHub connection"
  value       = aws_codestarconnections_connection.github.arn
}

output "github_connection_status" {
  description = "Status of the GitHub connection"
  value       = aws_codestarconnections_connection.github.status
}

output "artifacts_bucket_name" {
  description = "Name of the S3 bucket used for pipeline artifacts"
  value       = aws_s3_bucket.codepipeline_bucket.bucket
}
