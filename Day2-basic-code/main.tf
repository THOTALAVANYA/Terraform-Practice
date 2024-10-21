resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucket_name # Creating an S3 Bucket in AWS
}