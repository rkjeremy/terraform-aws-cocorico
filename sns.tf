# Here we create the SNS Topic with its subscribers.

resource "aws_sns_topic" "the_topic" {
  name = "${var.project_codename}-topic"
}

resource "aws_sns_topic_subscription" "the_sns_topic_subscription" {
  topic_arn = aws_sns_topic.the_topic.arn
  protocol  = "email"
  endpoint  = var.sns_topic_subscribers_email_address
}
