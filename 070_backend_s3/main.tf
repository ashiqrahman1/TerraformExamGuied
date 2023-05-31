terraform {
  backend "s3" {
    bucket = "terraform-backend-state-ashiq"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
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

data "aws_ssm_parameter" "my-amzn-linux-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "web" {
  ami           = data.aws_ssm_parameter.my-amzn-linux-ami.value
  instance_type = "t2.micro"
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
