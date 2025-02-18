# Here we create and configure a lambda function to be able to send its invocation records to a specific Cloudwatch Log Group

# We need to zip our code's file before uploading it into Lambda
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.mjs"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "the_lambda_function" {
  # depends_on = [
  #   aws_iam_role_policy_attachment.lambda_logs,
  #   aws_cloudwatch_log_group.the_lambda_cwlg,
  # ]

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
    }
  }

  logging_config {
    log_format = "JSON"
  }
}

## Grant CloudWatch Logs the permission to execute the function. 
resource "aws_lambda_permission" "the_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.the_lambda_function.function_name
  principal     = "logs.${var.aws_region}.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.the_trail_cwlg.arn}:*"
}
