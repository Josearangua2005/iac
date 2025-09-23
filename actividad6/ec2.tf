locals {
  instance_count = 2
  instance_name  = "act6-edgar-jose-server"
}

resource "aws_instance" "edgar-jose_server_terr" {
  count         = local.instance_count
  ami           = "ami-0ca4d5db4872d0c28"
  instance_type = var.instance_type
  tags = {
    Name = local.instance_name
  }
}

output "server_name" {
  value = aws_instance.edgar-jose_server_terr[0].tags.Name
}