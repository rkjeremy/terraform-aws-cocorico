variable "aws_region" {
  type        = string
  description = "The AWS region where resources will be provisioned."
  nullable    = false
}

variable "enable_logging" {
  type        = bool
  description = "Whether to enable trail logging or not."
  default     = true
}

variable "event_names" {
  type        = list(string)
  description = "The list of event names you want to monitor."
  default     = ["RunInstances", "TerminateInstances"]
}

variable "event_sources" {
  type        = list(string)
  description = "The event sources you want to monitor."
  default     = ["ec2.amazonaws.com", "lambda.amazonaws.com", "s3.amazonaws.com", "kms.amazonaws.com"]
}

variable "project_codename" {
  type        = string
  description = "The name you want to give the project. This will be used as prefix for many created resources."
  nullable    = false
  default     = "cocorico"
}

variable "sns_topic_subscribers_email_address" {
  type        = set(string)
  description = "The list of email addresses of people who want to receive the notification"
  default     = ["randriakj@gmail.com", "koloinaimaginieur@gmail.com"]
}
