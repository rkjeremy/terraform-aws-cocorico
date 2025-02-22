variable "aws_region" {
  type     = string
  nullable = false
}

variable "enable_logging" {
  type    = bool
  default = true
}

variable "event_names" {
  type    = list(string)
  default = ["RunInstances", "TerminateInstances"]
}

variable "event_sources" {
  type    = list(string)
  default = ["ec2.amazonaws.com", "lambda.amazonaws.com", "s3.amazonaws.com", "kms.amazonaws.com"]
}

variable "project_codename" {
  type     = string
  nullable = false
  default  = "cocorico"
}

variable "sns_topic_subscribers_email_address" {
  type        = set(string)
  description = "The list of email addresses of people who want to receive the notification"
  default     = ["randriakj@gmail.com", "koloinaimaginieur@gmail.com"]
}
