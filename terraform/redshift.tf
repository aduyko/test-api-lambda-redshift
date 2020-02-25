data "aws_secretsmanager_secret" "redshift" {
  name = var.redshift_secret_name
}

data "aws_secretsmanager_secret_version" "redshift" {
  secret_id = data.aws_secretsmanager_secret.redshift.id
}

resource "aws_redshift_cluster" "cluster" {
  cluster_identifier        = "${var.tag_app_name}-cluster"
  database_name             = "aduyko_serverless_test_db"
  master_username           = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_username"]
  master_password           = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_password"]
  node_type                 = "dc2.large"
  cluster_type              = "single-node"
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnets.name
  vpc_security_group_ids    = [aws_security_group.redshift.id]

  #Skip final snapshot for testing purposes
  skip_final_snapshot       = true

  depends_on = [aws_default_route_table.route_table]
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
