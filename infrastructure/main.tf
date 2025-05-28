
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0.0"
}

module "vpc" {
  source = "git::https://github.com/jefersonlemos/terraform.git//modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  routes = {
    "10.1.10.0/24" = {
      cidr_block  = "10.1.10.0/24"
      subnet_type = "private"
    }
    "10.1.20.0/24" = {
      cidr_block  = "10.1.20.0/24"
      subnet_type = "public"
    }
    "10.1.30.0/24" = {
      cidr_block  = "10.1.30.0/24"
      subnet_type = "private"
    }
    "10.1.40.0/24" = {
      cidr_block  = "10.1.40.0/24"
      subnet_type = "public"
    }
  }
}

module "eks" {
  # source = "git::https://github.com/jefersonlemos/terraform.git//modules/eks"
  source = "/home/jeferson/1.personal/poc/terraform/modules/eks"

  project_name                   = var.project_name
  cluster_name                   = local.full_name
  cluster_version                = "1.32"
  environment                    = var.environment
  cluster_endpoint_public_access = true

  vpc_id = module.vpc.vpc_id
  #TODO - Add nodes to a private subnet and permit only the public subnet to access the cluster 
  subnet_ids               = module.vpc.public_subnet_ids
  control_plane_subnet_ids = module.vpc.public_subnet_ids

  #TODO - Add addons

  #Define admin users
  define_admin_users                       = true
  enable_cluster_creator_admin_permissions = false
  access_entries = {
    eks_admin = {
      kubernetes_groups = []
      #TODO - Is it possible to give EKS permissions to a group instead of a role ?
      principal_arn = "arn:aws:iam::443370700365:role/EKSAdmin-role"

      policy_associations = {
        eks_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }


}

module "helm_sonnar_qube" {
  source = "git::https://github.com/jefersonlemos/terraform.git//modules/helm"
  # source = "/home/jeferson/1.personal/poc/terraform/modules/helm"
  
module "helm_jenkins" {
  # source = "git::https://github.com/jefersonlemos/terraform.git//modules/helm"
  source = "/home/jeferson/1.personal/poc/terraform/modules/helm"  

  name             = "jenkins"
  namespace        = "cicd"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  chart_version    = "5.8.53"
  create_namespace = true
  values = "helm-values/jenkins-values.yaml"
}