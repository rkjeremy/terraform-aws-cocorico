variable "aws_region" {
  type    = string
  default = "af-south-1"
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
  default = ["ec2.amazonaws.com", "lambda.amazonaws.com"]
}

variable "project_codename" {
  type    = string
  default = "cocorico"
}

variable "sns_topic_subscribers_email_address" {
  type    = set(string)
  default = ["randriakj@gmail.com", "koloinaimaginieur@gmail.com"]
}
