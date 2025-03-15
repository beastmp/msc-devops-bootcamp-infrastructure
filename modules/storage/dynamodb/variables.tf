# modules/storage/dynamodb/variables.tf
variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "component_role" {
  description = "Component role identifier for resource tagging"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Attribute to use as hash key"
  type        = string
  default     = "id"
}

variable "attributes" {
  description = "List of attribute definitions"
  type = list(object({
    name = string
    type = string
  }))
  default = [
    {
      name = "id"
      type = "S"
    }
  ]
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}