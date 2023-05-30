terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# resource "null_resource" "vpc" {
#   provisioner "local-exec" {
#     command = "aws ec2 describe-vpcs | jq -r '.Vpcs[].VpcId'"
#   }
# }

data "aws_vpc" "main" {
  default = true
}



resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.main.id
  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group_rule" "ingress_rule_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_tls.id
}

resource "aws_security_group_rule" "ingress_rule_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_tls.id
}

resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_tls.id
}

resource "aws_key_pair" "key" {
  key_name   = "myssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4hHp51J8MD7G2myJirx+J12CCXIdKP6wHPw+cmA25RNUua2rqiZpdi5eCCANaA9noztsh1fF4gaDC7oyPOxXlg8/hLFLbVXuDQE1FoMb6a0PI+IGMsxH4qW45uARKoRLgPs5Vl3eI2wXb2+V3JG96wKkis4+9lKFzGot1+VZP8Y1IPdVkdfj/Ey2Sqt7/8Zy6j//WRs5QStxoaYvnlgw1sEfst6SJpxRo/KmAWBTb7fJnUXhFsiH5lkvyvirer5PadPmhfUdYdIT74vDu2yDAsd7V6/zWYxM9UpbWHKz5w6qzSy0F1NmoNYH0SSp1jJ0jG/bwFjVDJG4luEmmEXhcfx8XyLHSgcmkpJiPOgwLrMt6M5k2NK5riXa+k9dyhiN8Dte7FujW8aJkeH9JYaR6iGVpVKFM2NxvfU1PvB0IIbvwEeNQgCzHa1+Goeuv5DpVoDAzsnwS6p9s6bphTe4KYjx9odW/KlHhm9nxMHzgA+kOhRorixIndZtjoE5LlPU= ashik@ubuntu"
}

resource "aws_instance" "web" {
  ami                    = "ami-0889a44b331db0194"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key.key_name
  user_data              = file("./installation.sh")
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  provisioner "remote-exec" {
    inline = ["echo ${self.private_ip} >> ~/priv8.txt"]
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/ashik/.ssh/terraform")
  }
}

resource "null_resource" "status_check" {
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.web.id}"
  }
  depends_on = [aws_instance.web]
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
