variable "global_variables" {
  type = object({
    project       = string
    region        = string
    account       = number
    is_production = bool
    prefix        = string
  })
  description = "Global variables for sharing across modules"
}

variable "s3_origin_bucket" {
  type = object({
    id                          = string
    arn                         = string
    bucket                      = string
    bucket_regional_domain_name = string
  })
  description = "S3 origin bucket attributes"
}

variable "cloudfront_cache_policy" {
  type        = string
  description = "(Required) CloudFront cache policy name. See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html for more details."
}

variable "cloudfront_origin_request_policy" {
  type        = string
  description = "(Optional) CloudFront origin request policy name. See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html for more details."
  default     = null

  validation {
    condition     = var.cloudfront_origin_request_policy != "Managed-AllViewer"
    error_message = "S3 expects the origin's host and cannot resolve the distribution's host."
  }
}

variable "cloudfront_response_headers_policy" {
  type        = string
  description = "(Optional) CloudFront response header policy name. See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html for more details."
  default     = null
}

variable "hosted_zone_name" {
  type        = string
  description = "(Required) The name of the hosted zone"
}

variable "app_sub_domain_name" {
  type        = string
  description = "(Optional) The sub domain name for the application"
  default     = null
}
