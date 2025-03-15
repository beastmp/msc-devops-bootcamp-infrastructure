# modules/storage/s3/variables.tf
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "component_role" {
  description = "Component role identifier for resource tagging"
  type        = string
}

variable "versioning_enabled" {
  description = "Whether versioning should be enabled for the bucket"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}