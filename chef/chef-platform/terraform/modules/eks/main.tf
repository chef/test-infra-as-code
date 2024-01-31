data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}

locals {
  azs       = slice(data.aws_availability_zones.available.names, 0, 3)
}



################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name                   = var.name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = var.production ? false : true

  vpc_id     = var.vpc_id                 #module.vpc.vpc_id

  control_plane_subnet_ids = var.cluster_subnet_ids       #control_plane_subnet_ids
  subnet_ids = var.cluster_subnet_ids                     #module.vpc.private_subnets


  create_cluster_security_group = true
  create_node_security_group    = true

#  fargate_profiles = {
#  }

#  fargate_profile_defaults = {
#    iam_role_additional_policies = {
#      additional = module.eks_blueprints_addons.fargate_fluentbit.iam_policy[0].arn
#    }
#  }


  eks_managed_node_groups = {
    edge_node_group = {
      instance_types = var.edge_instance_types
      subnet_ids = [var.cluster_subnet_ids[0], var.cluster_subnet_ids[1], var.cluster_subnet_ids[2]]

      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"

      min_size     = 3
      max_size     = 3
      desired_size = 3
    }
#    storage_node_group = {
#      instance_types = var.storage_instance_types

#      ami_type = "BOTTLEROCKET_x86_64"
#      platform = "bottlerocket"

#      min_size     = 0
#      max_size     = 3
#      desired_size = 1
#    }
  }

  tags = var.tags
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    #aws-ebs-csi-driver = {
    #  most_recent = true
    #}
    #coredns = {
    #  most_recent = true
    #}
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller    = true
  #enable_cluster_proportional_autoscaler = true
  #enable_karpenter                       = true
  #enable_kube_prometheus_stack           = true
  #enable_metrics_server                  = true
  #enable_external_dns                    = true
  #enable_cert_manager                    = true  

  aws_load_balancer_controller = {
    chart_version = "1.6.0" # min version required to use SG for NLB feature
  }

  tags = var.tags
}

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