# modules/container/ecr/variables.tf
variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "component_role" {
  description = "Component role identifier for resource tagging"
  type        = string
}

variable "mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether to scan images on push"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Whether to force delete the repository even if it contains images"
  type        = bool
  default     = false
}

variable "encryption_type" {
  description = "Encryption type for the repository (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "kms_key" {
  description = "KMS key ID to use when encryption_type is KMS"
  type        = string
  default     = null
}

# variable "description" {
#   description = "The description of the repository"
#   type        = string
#   default     = "Public ECR repository"
# }

# variable "about_text" {
#   description = "The About text for the repository"
#   type        = string
#   default     = ""
# }

# variable "usage_text" {
#   description = "The Usage text for the repository"
#   type        = string
#   default     = ""
# }

# variable "operating_systems" {
#   description = "The operating systems supported by the repository"
#   type        = list(string)
#   default     = ["Linux"]
# }

# variable "architectures" {
#   description = "The architecture types supported by the repository"
#   type        = list(string)
#   default     = ["ARM", "x86-64"]
# }

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}