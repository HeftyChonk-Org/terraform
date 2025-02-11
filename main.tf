locals {
  global_variables = {
    project       = "${var.project}"
    region        = "${var.region}"
    account       = "${var.account}"
    is_production = var.is_production
    branch        = "${var.branch}"
    prefix        = "${var.project}-${terraform.workspace}-${replace(var.branch, "/", "-")}"
  }
}

module "s3" {
  source           = "./modules/s3"
  global_variables = local.global_variables
}

module "db" {
  source                                = "./modules/db"
  global_variables                      = local.global_variables
  blog_table_max_read_request_units     = var.blog_table_max_read_request_units
  blog_table_max_write_request_units    = var.blog_table_max_write_request_units
  tag_ref_table_max_read_request_units  = var.tag_ref_table_max_read_request_units
  tag_ref_table_max_write_request_units = var.tag_ref_table_max_write_request_units
}

module "api" {
  source                 = "./modules/api"
  global_variables       = local.global_variables
  blog_table_name        = module.db.blog_table_name
  tag_ref_table_name     = module.db.tag_ref_table_name
  enable_account_logging = var.enable_account_logging
}

module "cdn" {
  source = "./modules/cdn"
  providers = {
    aws.virginia = aws.virginia
  }
  global_variables                   = local.global_variables
  s3_origin_bucket                   = module.s3.s3_origin_bucket
  cloudfront_cache_policy            = var.cloudfront_cache_policy
  cloudfront_origin_request_policy   = var.cloudfront_origin_request_policy
  cloudfront_response_headers_policy = var.cloudfront_response_headers_policy
  hosted_zone_name                   = var.hosted_zone_name
  app_sub_domain_name                = var.app_sub_domain_name
}
