resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
  acl    = "public-read"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*"
        }
    ]
}
EOF

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

  depends_on  = [aws_s3_bucket.bucket]
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
