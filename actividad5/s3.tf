resource "reandom_id" "bucket_suffix" {
    byte_length = 7
}

resource "aws_s3_bucket" "josetoño_bucket" {
    bucket = "josetoño-bucket-${random_id.bucket_suffix.hex}"
}

output "bucket_name" {
    value = aws_s3_bucket.josetoño_bucket.bucket
}