provider "aws" {
  region  = var.region
  profile = var.aws_cli_profile #"saml"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token  
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token  
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.cluster_auth.token  
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

################################################################################
# VPC
################################################################################
module "vpc" {
  source = "./modules/vpc"

  name        = join("-", [var.platform_name, var.enviornment])
  production  = var.production

  vpc_tags = {}
  tags = var.tags
}

################################################################################
# Cluster
################################################################################
module "eks" {
  source      = "./modules/eks"

  name = join("-", [var.platform_name, var.enviornment])
  production  = var.production
  cluster_version = var.cluster_version

  cluster_subnet_ids = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id

  tags = var.tags

}


# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 19.16"

#   cluster_name                   = "chef-platform-eks"
#   cluster_version                = "1.28"
#   cluster_endpoint_public_access = true ##this will have to change if we do production



#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   eks_managed_node_groups = {
#     core_node_group = {
#       instance_types = ["t3.medium"]

#       ami_type = "BOTTLEROCKET_x86_64"
#       platform = "bottlerocket"

#       min_size     = 3
#       max_size     = 3
#       desired_size = 3
#     }
#   }

#   tags = local.tags
# }

# module "eks_blueprints_addons" {
#   source  = "aws-ia/eks-blueprints-addons/aws"
#   version = "~> 1.0"

#   cluster_name      = module.eks.cluster_name
#   cluster_endpoint  = module.eks.cluster_endpoint
#   cluster_version   = module.eks.cluster_version
#   oidc_provider_arn = module.eks.oidc_provider_arn

#   enable_aws_load_balancer_controller = true
#   aws_load_balancer_controller = {
#     chart_version = "1.6.0" # min version required to use SG for NLB feature
#   }

#   tags = local.tags
# }


# ################################################################################
# # Ingress
# ################################################################################
# resource "aws_security_group" "ingress_nginx_external" {
#   name        = "ingress-nginx-external"
#   description = "Allow public HTTP and HTTPS traffic"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # modify to your requirements
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # modify to your requirements
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = local.tags
# }


# # ingress-nginx controller, exposed by an internet facing Network Load Balancer
# module "ingres_nginx_external" {
#   source  = "aws-ia/eks-blueprints-addons/aws"
#   version = "~> 1.0"

#   cluster_name      = module.eks.cluster_name
#   cluster_endpoint  = module.eks.cluster_endpoint
#   cluster_version   = module.eks.cluster_version
#   oidc_provider_arn = module.eks.oidc_provider_arn

#   enable_ingress_nginx = true
#   ingress_nginx = {
#     name = "ingress-nginx-external"
#     values = [
#       <<-EOT
#           controller:
#             replicaCount: 3
#             service:
#               annotations:
#                 service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
#                 service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
#                 service.beta.kubernetes.io/aws-load-balancer-security-groups: ${aws_security_group.ingress_nginx_external.id}
#                 service.beta.kubernetes.io/aws-load-balancer-manage-backend-security-group-rules: true
#               loadBalancerClass: service.k8s.aws/nlb
#             topologySpreadConstraints:
#               - maxSkew: 1
#                 topologyKey: topology.kubernetes.io/zone
#                 whenUnsatisfiable: ScheduleAnyway
#                 labelSelector:
#                   matchLabels:
#                     app.kubernetes.io/instance: ingress-nginx-external
#               - maxSkew: 1
#                 topologyKey: kubernetes.io/hostname
#                 whenUnsatisfiable: ScheduleAnyway
#                 labelSelector:
#                   matchLabels:
#                     app.kubernetes.io/instance: ingress-nginx-external
#             minAvailable: 2
#             ingressClassResource:
#               name: ingress-nginx-external
#               default: false
#         EOT
#     ]
#   }
# }