resource "aws_redshift_cluster" "cluster" {
  cluster_identifier        = "${var.tag_app_name}-cluster"
  database_name             = var.redshift_db_name
  master_username           = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_username"]
  master_password           = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_password"]
  node_type                 = "dc2.large"
  cluster_type              = "single-node"
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnets.name
  vpc_security_group_ids    = [aws_security_group.redshift.id]
  iam_roles                 = [module.iam_redshift.role.arn]

  #Skip final snapshot for testing purposes
  skip_final_snapshot       = true

  depends_on = [aws_default_route_table.route_table]
}

resource "null_resource" "redshift_db_setup" {
  depends_on = [aws_redshift_cluster.cluster]
  provisioner "local-exec" {
    command = "psql -h ${split(":", aws_redshift_cluster.cluster.endpoint)[0]} -p ${var.redshift_port} -U ${jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_username"]} -d ${var.redshift_db_name} -f ${path.module}/dist/redshift/init.sql"
    environment = {
      PGPASSWORD = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_password"]
    }
  }
}
