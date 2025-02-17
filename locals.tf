locals {
  trail_name           = "cocorico_trail"
  lambda_function_name = "cocorico_function"
}

locals {
  metric_filter_event_list = [for event in var.event_names : "$.eventName = \"${event}\""]
  metric_filter_pattern    = join(" || ", local.metric_filter_event_list)
}
