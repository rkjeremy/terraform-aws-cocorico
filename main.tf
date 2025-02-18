# Here we configure our CloudTrail trail to record write events and to send them to our CloudWatch Log Group

resource "aws_cloudtrail" "the_trail" {
  name                  = local.trail_name
  is_multi_region_trail = true
  s3_bucket_name        = aws_s3_bucket.the_bucket.id

  event_selector {
    read_write_type                  = "WriteOnly"
    exclude_management_event_sources = ["rdsdata.amazonaws.com"]
  }

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.the_trail_cwlg.arn}:*" # CloudTrail requires the Log Stream wildcard
  cloud_watch_logs_role_arn  = aws_iam_role.the_trail_s_role.arn
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}
