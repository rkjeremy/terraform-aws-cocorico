provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "Test"
      Feature     = title(var.project_codename)
    }
  }
}
