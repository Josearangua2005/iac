variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 (t2.micro es elegible para free tier)"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "production"
}

variable "public_key_path" {
  description = "Ruta a la clave pública SSH"
  type        = string
  default     = "/home/arangua/.ssh/doing.pub"
}

variable "private_key_path" {
  description = "Ruta a la clave privada SSH"
  type        = string
  default     = "/home/arangua/.ssh/doing"
}