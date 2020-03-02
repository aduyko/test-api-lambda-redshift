resource "aws_sqs_queue" "queue" {
  name                      = var.tag_app_name
  max_message_size          = 2048
  message_retention_seconds = 86400
}
