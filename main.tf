locals {
  global_variables = {
    project = "${var.project}"
    region  = "${var.region}"
    account = "${var.account}"
    branch  = "${var.branch}"
    prefix  = "${var.project}-${terraform.workspace}-${replace(var.branch, "/", "-")}"
  }
}

module "web" {
  source                             = "./modules/web"
  global_variables                   = local.global_variables
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
}