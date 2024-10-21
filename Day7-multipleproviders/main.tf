resource "aws_s3_bucket" "sample" {
  bucket = "bucket-for-multiple-provider"
}

resource "aws_s3_bucket" "test" {
  bucket   = "bucket-for-multiple-providers"
  provider = aws.california
}
