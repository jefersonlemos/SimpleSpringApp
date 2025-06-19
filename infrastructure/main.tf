
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

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "jlemos_key"
  create_private_key = true
}

module "ec2" {
  source = "git::https://github.com/jefersonlemos/terraform.git//modules/ec2"

  project_name = var.project_name
  ec2_instances = {
    "app_springboot" = {
      ami           = data.aws_ami.latest_amazon_linux.id
      instance_type = "t3a.nano"
      #TODO - There's a module improvement
      key_name   = module.key_pair.key_pair_name
      monitoring = false
      subnet_id  = module.vpc.public_subnet_ids[0]
      #TODO - There's a module improvement
      vpc_security_group_ids = [
        module.vpc.default_security_group_id
      ]
    }
  }
}

#Deploy steps
resource "null_resource" "run_s3_copy_script" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = module.ec2.instances["app_springboot"].private_ip
      private_key = module.key_pair.key_pair_name
    }

    inline = [
      "echo 'Starting S3 file copy...'",
      "aws s3 cp s3://spring-boot-app-demo bucket/spring-boot-app-demo-0.0.1-SNAPSHOT.jar /app/spring-boot-app-demo-0.0.1-SNAPSHOT.jar",
      "echo 'File copied from S3.'"
    ]
  }

  depends_on = [module.ec2]
}

  name             = "jenkins"
  namespace        = "cicd"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  chart_version    = "5.8.53"
  create_namespace = true
  values = "helm-values/jenkins-values.yaml"
}