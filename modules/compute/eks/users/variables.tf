# modules/compute/eks/users/variables.tf
variable "username" {
  description = "Username for the IAM user"
  type        = string
}

variable "groups" {
  description = "List of IAM groups to add the user to"
  type        = list(string)
  default     = []
}

variable "admin_group_name" {
  description = "Name of the administrators group"
  type        = string
  default     = "Administrators"
}

variable "console_access" {
  description = "Whether to create console access for the user"
  type        = bool
  default     = false
}

variable "programmatic_access" {
  description = "Whether to create an access key for the user"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Whether to force destroy the user even if it has non-Terraform resources"
  type        = bool
  default     = false
}

variable "secret_name" {
  description = "Name of the secret in AWS Secrets Manager"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}