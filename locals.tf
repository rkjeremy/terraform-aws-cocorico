locals {
  trail_name           = "${var.project_codename}_trail"
  lambda_function_name = "${var.project_codename}_function"
}

# locals {
#   metric_filter_event_list = [for event in var.event_names : "$.eventName = \"${event}\""]
#   metric_filter_pattern    = join(" || ", local.metric_filter_event_list)
# }

locals {
  metric_filter_event_source_list = [for source in var.event_sources : "$.eventSource = \"${source}\""]
  metric_filter_pattern           = join(" || ", local.metric_filter_event_source_list)
}
