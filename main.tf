terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "jose_server_terr" {
  ami           = "ami-0cfde0ea8edd312d4"
  instance_type = "t3.micro"

  tags = {
    Name = "joseServerTerr"
  }

}

resource "aws_s3_bucket" "jose_bucket" {
  bucket = "jose-terraform-bucket-012705"

  tags = {
    Name        = "joseBucketTerr"
    Environment = "dev"
  }
}

output "server_nam" {
  value = aws_instance.jose_server_terr.tags.Name
}

output "bucket_name" {
  value = aws_s3_bucket.jose_bucket.bucket
}