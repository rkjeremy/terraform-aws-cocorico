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

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.mjs"
  output_path = "lambda_function_payload.zip"
}

resource "aws_cloudwatch_log_group" "lambda_invocation_records" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 1
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:${data.aws_partition.current.partition}:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/${var.project_codename}/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_function" "logging" {
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_invocation_records,
  ]

  description = "This function publish an SNS message"

  filename      = "lambda_function_payload.zip"
  function_name = local.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.handler"
  runtime       = "nodejs22.x"
  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.sns_topic.arn
    }
  }

  logging_config {
    log_format = "JSON"
  }
}

## Grant CloudWatch Logs the permission to execute your function. 
resource "aws_lambda_permission" "logging" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.logging.function_name
  principal     = "logs.af-south-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.cocorico_cwlg.arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "logging" {
  depends_on      = [aws_lambda_permission.logging]
  destination_arn = aws_lambda_function.logging.arn

  #   Build the pattern dynamically
  filter_pattern = "{${local.metric_filter_pattern}}"

  log_group_name = aws_cloudwatch_log_group.cocorico_cwlg.name
  name           = "${var.project_codename}_logging"
}
