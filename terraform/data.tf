data "aws_secretsmanager_secret" "redshift" {
  name = var.redshift_secret_name
}

data "aws_secretsmanager_secret_version" "redshift" {
  secret_id = data.aws_secretsmanager_secret.redshift.id
}
