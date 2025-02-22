output "the_trail_id" {
  value       = aws_cloudtrail.the_trail.id
  description = "The new trail's ID"
}

output "the_bucket_id" {
  value       = aws_s3_bucket.the_bucket.id
  description = "The new bucket's ID"
}

output "the_lambda_function_id" {
  value       = aws_lambda_function.the_lambda_function.id
  description = "The new lambda's ID"
}
