# modules/compute/ec2/variables.tf
variable "name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name to use for the instance"
  type        = string
  default     = null
}

variable "component_role" {
  description = "Component role tag for the instance"
  type        = string
}

variable "platform" {
  description = "Platform type (linux, windows, etc.)"
  type        = string
}

variable "user_data" {
  description = "User data script for the instance"
  type        = string
  default     = ""
}

variable "root_volume_name" {
  description = "Name of the root volume"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
}

variable "availability_zone" {
  description = "AZ for the instance"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to deploy instances in"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the instance"
  type        = list(string)
  default     = []
}

variable "instance_role_name" {
  description = "Name for the EC2 IAM role"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile to attach to the instance"
  type        = string
}

variable "instance_policy_name" {
  description = "Name of the IAM instance policy"
  type        = string
}

variable "service_principal" {
  description = "AWS service principal for assume role policy"
  type        = string
  default     = "ec2.amazonaws.com"
}

variable "basic_permission_actions" {
  description = "List of basic permission actions to allow"
  type        = list(string)
  default     = []
}

variable "secret_name" {
  description = "Name of the secret in AWS Secrets Manager"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
