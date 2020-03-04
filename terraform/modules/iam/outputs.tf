output "role" {
  value = aws_iam_role.role
}

output "policy_attachments" {
  value = flatten([
    aws_iam_role_policy_attachment.policy_attachment,
    aws_iam_role_policy_attachment.managed_policy_attachments
  ])
}
