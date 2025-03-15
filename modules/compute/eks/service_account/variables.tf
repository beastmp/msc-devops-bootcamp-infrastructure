# modules/compute/eks/service_account/variables.tf
variable "role_name" {
  description = "Name of the IAM role for pod execution"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_ca_cert" {
  description = "Base64 encoded CA certificate for the EKS cluster"
  type        = string
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
  default     = "default"
}

variable "oidc_issuer_url" {
  description = "The URL of the OIDC issuer"
  type        = string
}

variable "oidc_thumbprint" {
  description = "The thumbprint of the OIDC provider certificate"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}