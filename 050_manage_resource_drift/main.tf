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

data "aws_ssm_parameter" "my-amzn-linux-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

locals {
  ingress_rule = [{
    from_port = 22
    to_port   = 22
    }, {
    from_port = 80
    to_port   = 80
  }]
}

data "aws_vpc" "main" {
  default = true
}

# resource "aws_security_group" "allow_ssh_web" {
#   name   = "web-sg"
#   vpc_id = data.aws_vpc.main.id

#   dynamic "ingress" {
#     for_each = local.ingress_rule
#     content {
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_key_pair" "key" {
#   key_name   = "sshKey"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4hHp51J8MD7G2myJirx+J12CCXIdKP6wHPw+cmA25RNUua2rqiZpdi5eCCANaA9noztsh1fF4gaDC7oyPOxXlg8/hLFLbVXuDQE1FoMb6a0PI+IGMsxH4qW45uARKoRLgPs5Vl3eI2wXb2+V3JG96wKkis4+9lKFzGot1+VZP8Y1IPdVkdfj/Ey2Sqt7/8Zy6j//WRs5QStxoaYvnlgw1sEfst6SJpxRo/KmAWBTb7fJnUXhFsiH5lkvyvirer5PadPmhfUdYdIT74vDu2yDAsd7V6/zWYxM9UpbWHKz5w6qzSy0F1NmoNYH0SSp1jJ0jG/bwFjVDJG4luEmmEXhcfx8XyLHSgcmkpJiPOgwLrMt6M5k2NK5riXa+k9dyhiN8Dte7FujW8aJkeH9JYaR6iGVpVKFM2NxvfU1PvB0IIbvwEeNQgCzHa1+Goeuv5DpVoDAzsnwS6p9s6bphTe4KYjx9odW/KlHhm9nxMHzgA+kOhRorixIndZtjoE5LlPU= ashik@ubuntu"
# }

resource "aws_instance" "ssh" {
  ami           = data.aws_ssm_parameter.my-amzn-linux-ami.value
  instance_type = "t2.micro"
  #   vpc_security_group_ids = [aws_security_group.allow_ssh_web.id]
  #   key_name               = aws_key_pair.key.key_name
}

output "instance" {
  value = aws_instance.ssh.public_ip
}
