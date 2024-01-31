variable "aws_cli_profile" {
  description = "The AWS CLI profile you will be using for credential access"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "enviornment" {
  description = "Name of the enviornment e.g. integration, uat, staging, production"
  type        = string
}

variable "production" {
  description = "Is this a production deployment"
  type        = bool
  default     = false
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.20"
}

variable "platform_name" {
  description = "What are we calling this platform"
  type        = string
  default     = "chef-platform"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}