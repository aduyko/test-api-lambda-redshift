resource "aws_iam_role" "role" {
  name = "iam_role_${var.resource_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "${var.service_name}.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name = var.resource_name
  path = "/"
  description = var.policy_description

  policy = templatefile("${path.module}/templates/${var.template_name}.json.tmpl", var.policy_template_variables)
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "managed_policy_attachments" {
  for_each = var.managed_policies

  role       = aws_iam_role.role.name
  policy_arn = each.value
}
