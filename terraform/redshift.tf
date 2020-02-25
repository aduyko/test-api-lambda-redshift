data "aws_secretsmanager_secret" "redshift" {
  name = var.redshift_secret_name
}

data "aws_secretsmanager_secret_version" "redshift" {
  secret_id = data.aws_secretsmanager_secret.redshift.id
}

resource "aws_redshift_cluster" "cluster" {
  cluster_identifier = "${var.tag_app_name}-cluster"
  database_name      = "aduyko_serverless_test_db"
  master_username    = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_username"]
  master_password    = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_password"]
  node_type          = "dc2.large"
  cluster_type       = "single-node"
}
/*
provider "postgresql" {
  host            = "postgres_server_ip"
  port            = 5432
  database        = "postgres"
  username        = "postgres_user"
  password        = "postgres_password"
  sslmode         = "require"
  connect_timeout = 15
}
*/
