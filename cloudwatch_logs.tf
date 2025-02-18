## 2.a. Let's create the Cloudwatch Log Group
resource "aws_cloudwatch_log_group" "cocorico_cwlg" {
  name              = "${var.project_codename}_cwlg"
  retention_in_days = 3 # for it is just for filtering purpose, we do not need to store these logs for a long time
}
