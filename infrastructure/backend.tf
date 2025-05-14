terraform {

  backend "s3" {
    bucket = "terraform-state-jefneu"
    key    = "terraform-vpc"
    region = "us-east-1"
  }
} 