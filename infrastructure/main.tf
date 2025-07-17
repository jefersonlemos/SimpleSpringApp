
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 5.0, < 6.1"
    version = ">= 5.0, < 6.1" }
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
  source = "git::https://github.com/jefersonlemos/terraform.git//modules/eks"
  # source = "/home/jeferson/1.personal/POC/SpringApp/terraform/modules/eks"

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
      principal_arn = "arn:aws:iam::077210449609:role/EKSAdmin-role"

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

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "jlemos_key"
  create_private_key = true
}

resource "local_file" "ec2_private_key" {
  content         = module.key_pair.private_key_pem
  filename        = "${path.module}/ec2-key.pem"
  file_permission = "0600"
}


module "ec2" {
  source = "git::https://github.com/jefersonlemos/terraform.git//modules/ec2"
  # source = "/home/jeferson/1.personal/POC/SpringApp/terraform/modules/ec2"

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

#TODO - Add the SG rule to allow access from EKS

#TODO - Create the App Bucket to store the application files  
#spring-boot-app-demo bucket

resource "aws_s3_bucket" "application_bucket" {
  bucket = "spring-boot-app-demo-bucket"
}

#Deploy steps
resource "null_resource" "deploy_app" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = module.ec2.ec2_instance_private_dns["app_springboot"]
      private_key = module.key_pair.private_key_pem
    }

    inline = [
      " echo 'Starting deployment of Spring Boot application...'",
      " sudo yum update -y",
      " sudo yum install java-17-amazon-corretto-headless -y",
      " sudo kill -9 $(ps aux | grep java | awk '{print $2}') || true ",
      " echo 'Starting S3 file copy...'",
      " sudo mkdir -p /app",
      " sudo chown -R ec2-user: /app",
      " aws s3 cp s3://spring-boot-app-demo-bucket/deployments/demo-0.0.1-SNAPSHOT.jar /app/spring-boot-app-demo-0.0.1-SNAPSHOT.jar",
      " echo 'Starting application...' ",
      " nohup java -jar /app/spring-boot-app-demo-0.0.1-SNAPSHOT.jar & disown",
    ]
  }

  depends_on = [module.ec2]

  triggers = {
    always_run = "${timestamp()}"
  }
}


# module "helm_sonnar_qube" {
#   # source = "git::https://github.com/jefersonlemos/terraform.git//modules/helm"
#   source = "/home/jeferson/1.personal/POC/SpringApp/terraform/modules/helm"

#   name             = "sonarqube"
#   repository       = "https://SonarSource.github.io/helm-chart-sonarqube"
#   chart            = "sonarqube"
#   namespace        = "sonarqube"
#   chart_version    = "2025.2.0"
#   create_namespace = true
#   values           = "helm-values/sonarQ-values.yaml"

# }
module "helm_jenkins" {
  source = "git::https://github.com/jefersonlemos/terraform.git//modules/helm"
  # source = "/home/jeferson/1.personal/POC/SpringApp/terraform/modules/helm"

  name             = "jenkins"
  namespace        = "cicd"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  chart_version    = "5.8.53"
  create_namespace = true
  values           = "helm-values/jenkins-values.yaml"
}