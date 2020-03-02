resource "aws_iam_role" "lambda_requestUnicorn" {
  name = "iam_for_lambda_requestUnicon"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_requestUnicorn" {
  name = "lambda_requestUnicorn"
  path = "/"
  description = "IAM policy for lambda requestUnicorn function for ${var.tag_app_name}"

  policy = templatefile("${path.module}/${var.templates_path}/lambda_requestUnicorn.json.tmpl", {
    sqs_queue_arn = aws_sqs_queue.queue.arn
  })
}

resource "aws_iam_role_policy_attachment" "lambda_requestUnicorn" {
  role       = aws_iam_role.lambda_requestUnicorn.name
  policy_arn = aws_iam_policy.lambda_requestUnicorn.arn
}

resource "aws_iam_role" "lambda_processQueue" {
  name = "iam_for_lambda_processQueue"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_processQueue" {
  name = "lambda_processQueue"
  path = "/"
  description = "IAM policy for lambda processQueue function for ${var.tag_app_name}"

  policy = templatefile("${path.module}/${var.templates_path}/lambda_processQueue.json.tmpl", {
    sqs_queue_arn  = aws_sqs_queue.queue.arn
    s3_bucket_name = aws_s3_bucket.redshift_bucket.arn
  })
}

resource "aws_iam_role_policy_attachment" "lambda_processQueue" {
  role       = aws_iam_role.lambda_processQueue.name
  policy_arn = aws_iam_policy.lambda_processQueue.arn
}

resource "aws_iam_role_policy_attachment" "lambda_processQueue_vpc" {
  role       = aws_iam_role.lambda_processQueue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole" 
}
