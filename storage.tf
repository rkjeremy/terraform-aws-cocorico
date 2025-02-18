# Here we create and configure an S3 bucket for our Cloudtrail trail to store its logs within.

resource "aws_s3_bucket" "the_bucket" {
  bucket_prefix = "${var.project_codename}-trail-logs-bucket-"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "the_bucket_policy" {
  bucket = aws_s3_bucket.the_bucket.id
  policy = data.aws_iam_policy_document.the_bucket_iam_policy_document.json
}
