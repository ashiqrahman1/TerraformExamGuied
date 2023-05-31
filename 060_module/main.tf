terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "main" {
  default = true
}
module "terraform_ec2_apache" {
  source        = "./terraform-aws-ec2-apache"
  instance_type = "t2.nano"
  vpc_id        = data.aws_vpc.main.id
}

output "apache" {
  value = module.terraform_ec2_apache.instance
}
