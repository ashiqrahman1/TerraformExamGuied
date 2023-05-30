resource "aws_instance" "web" {
  ami           = "ami-0889a44b331db0194"
  instance_type = var.instance
  tags = {
    "Name" = "TF_WEBSERVER"
  }
  provisioner "local-exec" {
    command = "echo Public ip is ${self.public_ip} >> ip.txt"
  }
}
