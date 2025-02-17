resource "aws_sns_topic" "sns_topic" {
  name = "${var.project_codename}-topic"
}

data "aws_iam_policy_document" "AllowPublishOnly_policy_doc" {
  statement {
    sid    = "AllowSNSPublishAPIOnly"
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [aws_sns_topic.sns_topic.arn]
  }
}

resource "aws_iam_policy" "AllowPublishOnly" {
  name        = "AllowPublishOnly"
  path        = "/${var.project_codename}/"
  description = "IAM policy for publishing an SNS message from a lambda"
  policy      = data.aws_iam_policy_document.AllowPublishOnly_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_sns" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.AllowPublishOnly.arn
}
