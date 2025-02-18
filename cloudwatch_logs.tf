# Here we create two Cloudwatch Log Groups.

# The first one is the Cloudwatch Log Group that our trail will send its logs to.
# And we'll create a Subscription Filter to filter/scan those logs to determine if any change has been made.
# And if it finds any occurencies, it will forward those logs to be processed by a Lambda function.
resource "aws_cloudwatch_log_group" "the_trail_cwlg" {
  name              = "${var.project_codename}_cwlg"
  retention_in_days = 3 # for it is just for filtering purpose, we do not need to store these logs for a long time
}

resource "aws_cloudwatch_log_subscription_filter" "the_subscription_filter" {
  # depends_on      = [aws_lambda_permission.the_lambda_permission]
  destination_arn = aws_lambda_function.the_lambda_function.arn

  filter_pattern = "{${local.metric_filter_pattern}}"

  log_group_name = aws_cloudwatch_log_group.the_trail_cwlg.name
  name           = "${var.project_codename}_subscription_filter"
}

# The second is a Log Group that will store the lambda function's invocation records.
resource "aws_cloudwatch_log_group" "the_lambda_cwlg" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 1
}
