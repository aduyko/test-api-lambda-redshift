resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
  acl    = "public-read"
  policy = templatefile("${path.module}/${var.templates_path}/s3_policy.json.tmpl", {
    bucket_name = var.s3_bucket_name,
  })

  website {
    index_document = "index.html"
  }

  tags = {
    Name = var.tag_app_name
  }
}

resource "aws_s3_bucket_object" "website_html" {
  for_each    = fileset("${path.module}/${var.s3_files_path}", "*.html")

  bucket      = var.s3_bucket_name
  key         = each.value
  source      = "${path.module}/${var.s3_files_path}/${each.value}"
  content_type= "text/html"

  depends_on  = [aws_s3_bucket.bucket]
}

resource "aws_s3_bucket_object" "website_js" {
  for_each    = fileset("${path.module}/${var.s3_files_path}/js", "**")

  bucket      = var.s3_bucket_name
  key         = "js/${each.value}"
  source      = "${path.module}/${var.s3_files_path}/js/${each.value}"
  content_type= "text/javascript"

  # Generate our configs before uploading
  depends_on  = [aws_s3_bucket.bucket, local_file.config]
}

resource "aws_s3_bucket_object" "website_css" {
  for_each    = fileset("${path.module}/${var.s3_files_path}/css", "*")

  bucket      = var.s3_bucket_name
  key         = "css/${each.value}"
  source      = "${path.module}/${var.s3_files_path}/css/${each.value}"
  content_type= "text/css"

  depends_on  = [aws_s3_bucket.bucket]
}

resource "aws_s3_bucket_object" "website_images" {
  for_each    = fileset("${path.module}/${var.s3_files_path}/images", "*")

  bucket      = var.s3_bucket_name
  key         = "images/${each.value}"
  source      = "${path.module}/${var.s3_files_path}/images/${each.value}"
  content_type= "image/${split(".",each.value)[1]}"

  depends_on  = [aws_s3_bucket.bucket]
}

resource "aws_s3_bucket_object" "website_icon" {
  for_each    = fileset("${path.module}/${var.s3_files_path}", "*.ico")

  bucket      = var.s3_bucket_name
  key         = each.value
  source      = "${path.module}/${var.s3_files_path}/${each.value}"
  content_type= "image/x-icon"

  depends_on  = [aws_s3_bucket.bucket]
}


output "s3_website_url" {
  value       = aws_s3_bucket.bucket.website_endpoint
  description = "S3 website URL"
}
