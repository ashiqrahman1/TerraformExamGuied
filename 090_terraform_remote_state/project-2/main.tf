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
  #   alias  = "us_east"
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../project-1/terraform.tfstate"
  }
}

module "terraform_aws_ec2_apache" {
  #   provider      = aws.us_east
  source        = "./terraform-aws-ec2-apache"
  vpc_id        = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_id     = data.terraform_remote_state.vpc.outputs.subnet_id[0]
  instance_type = "t2.micro"
}

output "public_ip" {
  value = module.terraform_aws_ec2_apache.instance
}
