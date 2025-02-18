data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "CloudTrail_CloudWatchLogs_Role" {
  name               = "CloudTrail_CloudWatchLogs_Role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

data "aws_iam_policy_document" "CloudTrail_CloudWatchLogs_Role_Policy" {
  statement {
    sid     = "AWSCloudTrailCreateLogStream2014110"
    actions = ["logs:CreateLogStream"]
    effect  = "Allow"
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cocorico_cwlg.name}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${data.aws_region.current.name}*"
    ]
  }

  statement {
    sid     = "AWSCloudTrailPutLogEvents20141101"
    effect  = "Allow"
    actions = ["logs:PutLogEvents"]
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cocorico_cwlg.name}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${data.aws_region.current.name}*"
    ]
  }
}

resource "aws_iam_policy" "cloudtrail-policy" {
  name        = "${var.project_codename}-cloudtrail-policy"
  description = "This policy grants CloudTrail the permissions required to create a CloudWatch Logs log stream in the log group ${aws_cloudwatch_log_group.cocorico_cwlg.name} and to deliver CloudTrail events to that log stream."
  policy      = data.aws_iam_policy_document.CloudTrail_CloudWatchLogs_Role_Policy.json
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.CloudTrail_CloudWatchLogs_Role.name
  policy_arn = aws_iam_policy.cloudtrail-policy.arn
}

resource "aws_cloudtrail" "cocorico_trail" {
  depends_on = [aws_s3_bucket_policy.cocorico_bucket_policy]

  name                  = local.trail_name
  is_multi_region_trail = true
  s3_bucket_name        = aws_s3_bucket.cocorico_bucket.id

  event_selector {
    read_write_type                  = "WriteOnly"
    exclude_management_event_sources = ["rdsdata.amazonaws.com"]
  }

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cocorico_cwlg.arn}:*" # CloudTrail requires the Log Stream wildcard
  cloud_watch_logs_role_arn  = aws_iam_role.CloudTrail_CloudWatchLogs_Role.arn
}

######################################################################################################################################################

# resource "aws_cloudwatch_log_metric_filter" "cwlog_metric_filter" {
#   name           = "cocorico_metric_filter"
#   log_group_name = aws_cloudwatch_log_group.cocorico_cwlg.name

#   # Build the pattern dynamically
#   pattern = "{${local.metric_filter_pattern}}"

#   metric_transformation {
#     name      = "CocoricoCount"
#     namespace = "Enhancement"
#     value     = "1"
#   }
# }


data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}
