resource "aws_instance" "edgar-jose_server_terr" {
  count = local.instance_count
  ami           = "ami-0ca4d5db4872d0c28"
  instance_type = var.instance_type

  tags = {
    Name = local.instance_name
  }

}

output "server_name" {
  value = aws_instance.edgar-jose_server_terr.tags.Name
}