# S3

## 1.a. First we create the bucket to store our API events logs from Cloudtrail
resource "aws_s3_bucket" "cocorico_bucket" {
  bucket_prefix = "cocorico-trails-"
  force_destroy = true
}

## 1.b. And we have to give the CloudTrail service permission to put objects inside this bucket through this policy
data "aws_iam_policy_document" "cocorico_iam_policy_document" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cocorico_bucket.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.trail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cocorico_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.trail_name}"]
    }
  }
}

## 1.c. Then we create the bucket policy
resource "aws_s3_bucket_policy" "cocorico_bucket_policy" {
  bucket = aws_s3_bucket.cocorico_bucket.id
  policy = data.aws_iam_policy_document.cocorico_iam_policy_document.json
}
