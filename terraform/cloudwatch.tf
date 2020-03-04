resource "aws_cloudwatch_event_rule" "trigger_lambda" {
  name                = "TriggerLambda"
  description         = "Trigger processQueue lambda every ${var.sqs_process_frequency} minutes"
  schedule_expression = "rate(${var.sqs_process_frequency} minutes)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.trigger_lambda.id
  arn       = module.lambda_processQueue.lambda.arn
  input     = "{}"
}
