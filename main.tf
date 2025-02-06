locals {
  global_variables = {
    project = "${var.project}"
    region  = "${var.region}"
    account = "${var.account}"
    branch  = "${var.branch}"
    prefix  = "${var.project}-${terraform.workspace}-${replace(var.branch, "/", "-")}"
  }
}

module "s3" {
  source           = "./modules/s3"
  global_variables = local.global_variables
}

module "cdn" {
  source                             = "./modules/cdn"
  global_variables                   = local.global_variables
  s3_origin_bucket                   = module.s3.s3_origin_bucket
  cloudfront_cache_policy            = var.cloudfront_cache_policy
  cloudfront_origin_request_policy   = var.cloudfront_origin_request_policy
  cloudfront_response_headers_policy = var.cloudfront_response_headers_policy
}

module "api" { 
  source           = "./modules/api"
  global_variables = local.global_variables
}

module "db" {
  source           = "./modules/db"
  global_variables = local.global_variables
  main_table_max_read_request_units = var.main_table_max_read_request_units
  main_table_max_write_request_units = var.main_table_max_write_request_units
  tag_ref_table_max_read_request_units = var.tag_ref_table_max_read_request_units
  tag_ref_table_max_write_request_units = var.tag_ref_table_max_write_request_units
}