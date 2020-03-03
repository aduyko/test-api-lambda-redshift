data "aws_secretsmanager_secret" "redshift" {
  name = var.redshift_secret_name
}

data "aws_secretsmanager_secret_version" "redshift" {
  secret_id = data.aws_secretsmanager_secret.redshift.id
}

data "aws_sqs_queue" "queue" {
  name = aws_sqs_queue.queue.name

  depends_on = [aws_sqs_queue.queue]
}
