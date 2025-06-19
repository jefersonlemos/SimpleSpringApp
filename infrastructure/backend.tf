terraform {

  backend "s3" {
    bucket = "terraform-state-springboot-poc"
    key    = "terraform-vpc"
    region = "us-east-1"
  }
} 