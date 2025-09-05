resource "aws_instance" "jose_server_terr" {
  ami           = "ami-0cfde0ea8edd312d4"
  instance_type = "t3.micro"

  tags = {
    Name = "joseServerTerr"
  }

}

output "server_nam" {
  value = aws_instance.jose_server_terr.tags.Name
}