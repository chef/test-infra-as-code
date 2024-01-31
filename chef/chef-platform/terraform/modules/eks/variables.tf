variable "cluster_version" {
  description = "EKS Version"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string  
}

variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane"
  type        = list(string)
  default     = []
}

variable "cluster_subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
  default     = []
}

variable "name" {
  description = "Name of the Cluster"
  type        = string
  default     = "chef-platform"
}

variable "production" {
  description = "Is the stack a production deployment"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "edge_instance_types" {
  description = "Set of instance types associated with the EKS Edge Node Group. Defaults to `[\"t3.medium\"]`"
  type        = list(string)
  default     = null
}

variable "storage_instance_types" {
  description = "Set of instance types associated with the EKS Database Node Group. Defaults to `[\"t3.medium\"]`"
  type        = list(string)
  default     = null
}
