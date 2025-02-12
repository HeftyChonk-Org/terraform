resource "aws_s3_bucket" "origin_bucket" {
  bucket        = substr("${var.global_variables.prefix}-origin-bucket", 0, 63)
  force_destroy = var.global_variables.is_production ? false : true
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