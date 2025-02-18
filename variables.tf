# variable "aws_access_key" {
#   type     = string
#   nullable = false
# }

variable "aws_region" {
  type    = string
  default = "af-south-1"
}

# variable "aws_secret_key" {
#   type      = string
#   nullable  = false
#   sensitive = true
# }

variable "aws_profile" {
  type     = string
  nullable = false
}

variable "event_names" {
  type    = list(string)
  default = ["RunInstances", "TerminateInstances"]
}

variable "project_codename" {
  type    = string
  default = "cocorico"
}

variable "sns_topic_subscribers_email_address" {
  type    = string
  default = "randriakj@gmail.com"
}
