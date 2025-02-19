# Cocorico

This module aims to notify you via email whenever a resource is added, modified, or even deleted within your AWS account across all regions.

## How it works

Diagram coming here soon !

## Installation

### Prerequesites

Of course you would need Terraform to be installed on your system. If not yet, follow this tutorial on [how to install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

You would also need AWS CLI as this module will use the default logged-in user profile within your system to perform all required operations. Check these links for the [installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and the [configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-methods) process.

### Steps

First prepares your workspace so Terraform can apply your configuration.

```bash
terraform init
```

Then, get a preview of the changes Terraform will make before you apply them.

```bash
terraform plan
```

Finally, if your configuration is okey, you can apply to deploy the solution.

```bash
terraform apply [-auto-approve]
```

## Issues

I noticed that, during a certain period of time, if you did not change the project_name variable after a destroy, the Cloudwatch Log Group does not update its stream on the next re-apply, even if the trail keeps sending its logs to the S3 bucket. Maybe it is because of a certain caching mechanism inside the AWS code.

## Resources

[Sending events to CloudWatch Logs](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/send-cloudtrail-events-to-cloudwatch-logs.html)

[Real-time processing of log data with subscriptions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Subscriptions.html)

## Author

Jeremy RANDRIANARIVONY
