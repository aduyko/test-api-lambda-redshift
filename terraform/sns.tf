resource "aws_sns_topic" "topic" {
  name = var.tag_app_name
}

resource "aws_sns_topic_subscription" "lambda_redshiftCopy" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.redshiftCopy.arn
}
