output "s3_origin_bucket" {
  value = {
    id                          = aws_s3_bucket.origin_bucket.id
    bucket_regional_domain_name = aws_s3_bucket.origin_bucket.bucket_regional_domain_name
    bucket                      = aws_s3_bucket.origin_bucket.bucket
    arn                         = aws_s3_bucket.origin_bucket.arn
  }
}