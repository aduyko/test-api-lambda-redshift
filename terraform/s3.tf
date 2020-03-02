resource "aws_s3_bucket" "redshift_bucket" {
  bucket = "${var.tag_app_name}-redshift"

  tags = {
    Name = "${var.tag_app_name}-redshift"
  }
}

resource "aws_s3_bucket" "www_bucket" {
  bucket = "${var.tag_app_name}-www"
  policy = templatefile("${path.module}/${var.templates_path}/s3_policy.json.tmpl", {
    bucket_name = "${var.tag_app_name}-www",
  })

  website {
    index_document = "index.html"
  }

  tags = {
    Name = "${var.tag_app_name}-www"
  }
}

resource "aws_s3_bucket_object" "website_html" {
  for_each    = fileset("${path.module}/${var.s3_files_path}", "*.html")

  bucket      = "${var.tag_app_name}-www"
  key         = each.value
  source      = "${path.module}/${var.s3_files_path}/${each.value}"
  content_type= "text/html"

  depends_on  = [aws_s3_bucket.www_bucket]
}

resource "aws_s3_bucket_object" "website_js" {
  for_each    = fileset("${path.module}/${var.s3_files_path}/js", "**")

  bucket      = "${var.tag_app_name}-www"
  key         = "js/${each.value}"
  source      = "${path.module}/${var.s3_files_path}/js/${each.value}"
  content_type= "text/javascript"

  # Generate our configs before uploading
  depends_on  = [aws_s3_bucket.www_bucket, local_file.config]
}

resource "aws_s3_bucket_object" "website_css" {
  for_each    = fileset("${path.module}/${var.s3_files_path}/css", "*")

  bucket      = "${var.tag_app_name}-www"
  key         = "css/${each.value}"
  source      = "${path.module}/${var.s3_files_path}/css/${each.value}"
  content_type= "text/css"

  depends_on  = [aws_s3_bucket.www_bucket]
}

resource "aws_s3_bucket_object" "website_images" {
  for_each    = fileset("${path.module}/${var.s3_files_path}/images", "*")

  bucket      = "${var.tag_app_name}-www"
  key         = "images/${each.value}"
  source      = "${path.module}/${var.s3_files_path}/images/${each.value}"
  content_type= "image/${split(".",each.value)[1]}"

  depends_on  = [aws_s3_bucket.www_bucket]
}

resource "aws_s3_bucket_object" "website_icon" {
  for_each    = fileset("${path.module}/${var.s3_files_path}", "*.ico")

  bucket      = "${var.tag_app_name}-www"
  key         = each.value
  source      = "${path.module}/${var.s3_files_path}/${each.value}"
  content_type= "image/x-icon"

  depends_on  = [aws_s3_bucket.www_bucket]
}

# Generate config file for app using cognito and api gateway sources
resource "local_file" "config" {
  filename  = "${path.module}/${var.s3_files_path}/js/config.js"
  content   = templatefile("${path.module}/${var.templates_path}/config.js.tmpl", {
    user_pool_id        = aws_cognito_user_pool.pool.id,
    user_pool_client_id = aws_cognito_user_pool_client.client.id,
    region              = var.aws_region
    invoke_url          = aws_api_gateway_deployment.deployment.invoke_url
  })

  depends_on = [aws_cognito_user_pool_client.client, aws_api_gateway_deployment.deployment]
}
