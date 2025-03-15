# modules/compute/ec2/iam/variables.tf
variable "role_name" {
  description = "Name for the IAM role"
  type        = string
}

variable "service_principal" {
  description = "AWS service principal that can assume this role"
  type        = string
  default     = "ec2.amazonaws.com"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}