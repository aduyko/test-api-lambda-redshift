output "api_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

output "s3_website_url" {
  value       = aws_s3_bucket.bucket.website_endpoint
  description = "S3 website URL"
}
