resource "aws_s3_bucket" "bucket_alb_log" {
  bucket  = "${var.service_name}-alb-log-${var.env}"
}

data "aws_iam_policy_document" "policy_document_alb_log" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::582318560864:root"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.bucket_alb_log.bucket}/*"]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.bucket_alb_log.bucket}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.bucket_alb_log.bucket}"]
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_alb_log" {
  bucket = aws_s3_bucket.bucket_alb_log.id
  policy = data.aws_iam_policy_document.policy_document_alb_log.json
}

resource "aws_s3_bucket_policy" "bucket_policy_image" {
  bucket = aws_s3_bucket.bucket_service_image.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.bucket_service_image.id}/*"
      }
    ]
  })
}

resource "aws_s3_bucket" "bucket_service_image" {
  bucket  = "image.botapeer.com"
}

resource "aws_s3_bucket_website_configuration" "bucket_service_image_config" {
  bucket = aws_s3_bucket.bucket_service_image.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket" "bucket_cloudfront" {
  bucket  = "${var.service_name}-cloudfront-${var.env}"
}

data "aws_iam_policy_document" "policy_document_cloudfront_log" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl",
                "s3:PutBucketAcl"
                ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.bucket_cloudfront.bucket}"]
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_cloudfront_log" {
  bucket = aws_s3_bucket.bucket_cloudfront.id
  policy = data.aws_iam_policy_document.policy_document_cloudfront_log.json
}
