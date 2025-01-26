resource "aws_s3_bucket" "origin_bucket" {
  bucket = substr("${var.global_variables.prefix}-origin-bucket", 0, 63)
  force_destroy = strcontains(terraform.workspace, "prod") ? false : true
}

resource "aws_s3_bucket" "origin_access_log_bucket" {
  bucket = substr("${var.global_variables.prefix}-origin-access-log-bucket", 0, 63)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_sse" {
  for_each = {
    origin_bucket            = aws_s3_bucket.origin_bucket.id,
    origin_access_log_bucket = aws_s3_bucket.origin_access_log_bucket.id
  }
  bucket = each.value

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_logging" "origin_bucket_logging" {
  bucket        = aws_s3_bucket.origin_bucket.id
  target_bucket = aws_s3_bucket.origin_access_log_bucket.id
  target_prefix = "access_log/"

  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "origin_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.origin_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "origin_bucket_cors" {
  bucket = aws_s3_bucket.origin_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://s3-website-test.hashicorp.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

data "aws_iam_policy_document" "allow_logs_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.origin_access_log_bucket.arn}",
      "${aws_s3_bucket.origin_access_log_bucket.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [tostring(var.global_variables.account)]
    }
  }
}

resource "aws_s3_bucket_policy" "origin_access_log_bucket_policy" {
  bucket = aws_s3_bucket.origin_access_log_bucket.id
  policy = data.aws_iam_policy_document.allow_logs_access.json
}

# ==========================================================================================
# CloudFront
# ==========================================================================================

data "aws_cloudfront_cache_policy" "cache_policy" {
  name = var.cloudfront_cache_policy
}

data "aws_cloudfront_origin_request_policy" "origin_request_policy" {
  count = var.cloudfront_origin_request_policy != null ? 1 : 0
  name = var.cloudfront_origin_request_policy
}

data "aws_cloudfront_response_headers_policy" "response_header_policy" {
  count = var.cloudfront_response_headers_policy != null ? 1 : 0
  name = var.cloudfront_response_headers_policy
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${aws_s3_bucket.origin_bucket.bucket}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "no-override"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.origin_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    origin_id                = aws_s3_bucket.origin_bucket.id
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy     = "redirect-to-https"
    target_origin_id           = aws_s3_bucket.origin_bucket.id
    cache_policy_id            = data.aws_cloudfront_cache_policy.cache_policy.id
    origin_request_policy_id   = var.cloudfront_origin_request_policy != null ? data.aws_cloudfront_origin_request_policy.origin_request_policy.0.id : null
    response_headers_policy_id = var.cloudfront_response_headers_policy != null ? data.aws_cloudfront_response_headers_policy.response_header_policy.0.id : null
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# ==========================================================================================
# CloudFront OAC
# ==========================================================================================

data "aws_iam_policy_document" "allow_public_access" {
  policy_id = "PolicyForCloudFrontPrivateContent"

  statement {
    sid     = "AllowCloudFrontServicePrincipal"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    resources = ["${aws_s3_bucket.origin_bucket.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.origin_bucket.arn}"]

    principals {
      type        = "AWS"
      identifiers = [tostring(var.global_variables.account)]
    }
  }
}

resource "aws_s3_bucket_policy" "origin_bucket_policy" {
  bucket = aws_s3_bucket.origin_bucket.id
  policy = data.aws_iam_policy_document.allow_public_access.json
}
