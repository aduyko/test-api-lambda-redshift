resource "aws_cognito_user_pool" "pool" {
  name = var.tag_app_name
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${var.tag_app_name}-client"

  user_pool_id = aws_cognito_user_pool.pool.id
}

# Generate config file for app based on above cognito resources
resource "local_file" "config" {
  filename = "${path.module}/${var.s3_files_path}/js/config.js"
  content = templatefile("${path.module}/${var.templates_path}/config.js.tmpl", {
    user_pool_id = aws_cognito_user_pool.pool.id,
    user_pool_client_id = aws_cognito_user_pool_client.client.id,
    region = var.aws_region
  })

  depends_on = [aws_cognito_user_pool_client.client]
}
