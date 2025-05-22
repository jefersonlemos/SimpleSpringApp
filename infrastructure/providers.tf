provider "aws" {
  default_tags {
    tags = {
      Name        = local.full_name
      Environment = var.environment
      Terraform   = "true"
      CreatedBy   = "Terraform"
    }
  }
}

provider "helm" {
    kubernetes {
      host               = module.eks.cluster_endpoint
      cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
        exec {
            api_version = "client.authentication.k8s.io/v1beta1"
            args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name,
            "--role-arn", "arn:aws:iam::443370700365:role/EKSAdmin-role"]
            command     = "aws"
        }
    }
}

provider "kubernetes" {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
      exec {
            api_version = "client.authentication.k8s.io/v1beta1"
            args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name,
            "--role-arn", "arn:aws:iam::443370700365:role/EKSAdmin-role"]
            command     = "aws"
        }
}