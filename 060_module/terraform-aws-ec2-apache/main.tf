data "aws_ssm_parameter" "my-amzn-linux-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# data "aws_vpc" "main" {
#   default = true
# }

locals {
  ingress = [{
    from_port = 22
    to_port   = 22
    }, {
    from_port = 80
    to_port   = 80
  }]
}


resource "aws_security_group" "mysg" {
  name        = "module-sg"
  description = "allow http and ssh connection"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.my-amzn-linux-ami.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.mysg.id]
  user_data              = file("${path.module}/installation.sh")
  tags = {
    Name = "apache"
  }
}
