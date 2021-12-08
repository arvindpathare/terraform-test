resource "aws_s3_bucket" "b" {

  bucket = "s3-terraform-bucket-srk-terra-test"

  acl    = "private"

  tags = {

    Name        = "My bucket"

    Environment = "Test"

  }

}

# Upload an object
resource "aws_s3_bucket_object" "object" {

  bucket = aws_s3_bucket.b.id

  key    = "profile"

  acl    = "private"

  source = "/root/terraform-test/index.html"

  etag = filemd5("/root/terraform-test/index.html")

}
