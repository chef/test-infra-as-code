variable "name" {
  description = "Name of the VPC"
  type        = string
  default     = "chef-platform"
}

variable "production" {
  description = "Is the stack a production deployment"
  type        = bool
  default     = false
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}