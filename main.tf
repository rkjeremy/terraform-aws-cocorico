# Here we create and configure an S3 bucket for our Cloudtrail trail to store its logs within.

resource "aws_s3_bucket" "the_bucket" {
  bucket_prefix = "${var.project_codename}-trail-logs-bucket-"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "the_bucket_policy" {
  bucket = aws_s3_bucket.the_bucket.id
  policy = data.aws_iam_policy_document.the_bucket_iam_policy_document.json
}

# Here we configure our CloudTrail trail to record write events and to send them to our CloudWatch Log Group

resource "aws_cloudtrail" "the_trail" {
  enable_logging        = var.enable_logging
  name                  = local.trail_name
  is_multi_region_trail = true
  s3_bucket_name        = aws_s3_bucket.the_bucket.id

  advanced_event_selector {
    name = "Log all management events except Amazon RDS Data API management events"
    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
    field_selector {
      field      = "eventSource"
      equals     = var.event_sources
      not_equals = ["rdsdata.amazonaws.com"]
    }
    field_selector {
      field  = "readOnly"
      equals = [false]
    }
  }

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.the_trail_cwlg.arn}:*" # CloudTrail requires the Log Stream wildcard
  cloud_watch_logs_role_arn  = aws_iam_role.the_trail_s_role.arn
}

###########################################################################################################################################################

# Here we create the Cloudwatch Log Group that our trail will send its logs to.
# And we'll create a Subscription Filter to filter/scan those logs to determine if any change has been made.
# And if it finds any occurencies, it will forward those logs to be processed by a Lambda function.
resource "aws_cloudwatch_log_group" "the_trail_cwlg" {
  name              = "${var.project_codename}_cwlg"
  retention_in_days = 3 # for it is just for filtering purpose, we do not need to store these logs for a long time
}

resource "aws_cloudwatch_log_subscription_filter" "the_subscription_filter" {
  destination_arn = aws_lambda_function.the_lambda_function.arn

  filter_pattern = "{${local.metric_filter_pattern}}"

  log_group_name = aws_cloudwatch_log_group.the_trail_cwlg.name
  name           = "${var.project_codename}_subscription_filter"
}

## Grant CloudWatch Logs the permission to execute the function. 
resource "aws_lambda_permission" "the_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.the_lambda_function.function_name
  principal     = "logs.${var.aws_region}.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.the_trail_cwlg.arn}:*"
}

#####################################################################################################################################################

# Here we create and configure the lambda function that will send the SNS notification

## Here is the SNS Topic we will use.
resource "aws_sns_topic" "the_topic" {
  name = "${var.project_codename}-topic"
}
## And this is its subscription
resource "aws_sns_topic_subscription" "the_sns_topic_subscription" {
  for_each  = var.sns_topic_subscribers_email_address
  topic_arn = aws_sns_topic.the_topic.arn
  protocol  = "email"
  endpoint  = each.key
}


# We need to zip our code's file before uploading it into Lambda
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.mjs"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "the_lambda_function" {
  description = "This function will publish an SNS message."

  filename      = "lambda_function_payload.zip"
  function_name = local.lambda_function_name
  role          = aws_iam_role.the_lambda_function_role.arn
  handler       = "lambda.handler"
  runtime       = "nodejs22.x"
  environment {
    variables = {
      TOPIC_ARN    = aws_sns_topic.the_topic.arn
      PROJECT_NAME = var.project_codename
      REGION       = var.aws_region
    }
  }

  logging_config {
    log_format = "JSON"
  }
}

# This second Log Group will store the lambda function's invocation records.
resource "aws_cloudwatch_log_group" "the_lambda_cwlg" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 1
}
