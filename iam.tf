###############################################################################################################################################################

data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "the_trail_s_role" {
  name               = "CloudTrail_CloudWatchLogs_Role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

data "aws_iam_policy_document" "CloudTrail_CloudWatchLogs_Role_Policy" {
  statement {
    sid     = "AWSCloudTrailCreateLogStream2014110"
    actions = ["logs:CreateLogStream"]
    effect  = "Allow"
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.the_trail_cwlg.name}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${data.aws_region.current.name}*"
    ]
  }

  statement {
    sid     = "AWSCloudTrailPutLogEvents20141101"
    effect  = "Allow"
    actions = ["logs:PutLogEvents"]
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.the_trail_cwlg.name}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${data.aws_region.current.name}*"
    ]
  }
}

resource "aws_iam_policy" "the_trail_iam_policy" {
  name        = "${var.project_codename}_trail_policy"
  path        = "/${var.project_codename}/"
  description = "This policy grants the trail the permissions required to create a CloudWatch Logs log stream in the log group ${aws_cloudwatch_log_group.the_trail_cwlg.name} and to deliver CloudTrail events to that log stream."
  policy      = data.aws_iam_policy_document.CloudTrail_CloudWatchLogs_Role_Policy.json
}

resource "aws_iam_role_policy_attachment" "trail_cwlg_role_policy_attachment" {
  role       = aws_iam_role.the_trail_s_role.name
  policy_arn = aws_iam_policy.the_trail_iam_policy.arn
}

################################################################################################################################################################

data "aws_iam_policy_document" "the_bucket_iam_policy_document" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.the_bucket.arn]
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
    resources = ["${aws_s3_bucket.the_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

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

##################################################################################################################################################################

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "the_lambda_function_role" {
  name               = "${var.project_codename}_lambda_function"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "the_function_policy_document" {
  statement {
    sid    = "AllowToWriteIntoCloudwatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:${data.aws_partition.current.partition}:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "the_function_iam_policy" {
  name        = "lambda_logging"
  path        = "/${var.project_codename}/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.the_function_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_cwlg_role_policy_attachment" {
  role       = aws_iam_role.the_lambda_function_role.name
  policy_arn = aws_iam_policy.the_function_iam_policy.arn
}

#############################################################################################################################################################

data "aws_iam_policy_document" "AllowPublishOnly_policy_doc" {
  statement {
    sid    = "AllowSNSPublishAPIOnly"
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [aws_sns_topic.the_topic.arn]
  }
}

resource "aws_iam_policy" "AllowPublishOnly" {
  name        = "AllowPublishOnly"
  path        = "/${var.project_codename}/"
  description = "IAM policy for publishing an SNS message from a lambda"
  policy      = data.aws_iam_policy_document.AllowPublishOnly_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_sns_role_policy_attachment" {
  role       = aws_iam_role.the_lambda_function_role.name
  policy_arn = aws_iam_policy.AllowPublishOnly.arn
}
