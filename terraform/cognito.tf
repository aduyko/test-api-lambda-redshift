resource "aws_cognito_user_pool" "pool" {
  name = var.tag_app_name
}

resource "aws_cognito_user_pool_client" "client" {
  name          = "${var.tag_app_name}-client"
  user_pool_id  = aws_cognito_user_pool.pool.id
}
