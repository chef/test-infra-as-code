data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>5.4.0"

  name = var.name

  cidr                  = "10.0.0.0/24"
  secondary_cidr_blocks = ["10.10.0.0/16", "10.110.0.0/16"]

  azs                   = local.azs
  public_subnets        = ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"] #10.0.0.192/26	
  public_subnet_names   = ["Public AZa","Public AZb","Public AZc"]
  
  private_subnets       = ["10.10.0.0/18", "10.10.64.0/18", "10.10.128.0/18", "10.110.0.0/18", "10.110.64.0/18", "10.110.128.0/18"]
  private_subnet_names  = ["Managed Nodes AZa", "Managed Nodes AZb", "Managed Nodes AZc", "Fargate Nodes AZa", "Fargate Nodes AZb", "Fargate Nodes AZc"]

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  #NAT GATEWAY
  enable_nat_gateway      =  true
  single_nat_gateway      = var.production ? false : true
  one_nat_gateway_per_az  = var.production ? true : false

  enable_vpn_gateway = false
  enable_dhcp_options              = false

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = false
  create_flow_log_cloudwatch_log_group = false
  create_flow_log_cloudwatch_iam_role  = false
  flow_log_max_aggregation_interval    = 60

  vpc_tags = var.vpc_tags
  tags = var.tags
}



# resource "aws_security_group" "rds" {
#   name_prefix = "${local.name}-rds"
#   description = "Allow PostgreSQL inbound traffic"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description = "TLS from VPC"
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = [module.vpc.vpc_cidr_block]
#   }

#   tags = local.tags
# }