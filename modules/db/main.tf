resource "aws_dynamodb_table" "blog_table" {
  name                        = "${var.global_variables.prefix}-blog-table"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "Type"
  range_key                   = "Slug"
  deletion_protection_enabled = var.global_variables.is_production

  attribute {
    name = "Type"
    type = "S"
  }

  attribute {
    name = "Slug"
    type = "S"
  }

  attribute {
    name = "Category"
    type = "S"
  }

  attribute {
    name = "PublishDate"
    type = "S"
  }

  attribute {
    name = "SubCategory"
    type = "S"
  }

  on_demand_throughput {
    max_read_request_units  = var.blog_table_max_read_request_units
    max_write_request_units = var.blog_table_max_write_request_units
  }

  global_secondary_index {
    name               = "CategoryIndex"
    hash_key           = "Category"
    range_key          = "PublishDate"
    projection_type    = "INCLUDE"
    non_key_attributes = ["SubCategory", "Slug"]
  }

  global_secondary_index {
    name               = "SubCategoryIndex"
    hash_key           = "SubCategory"
    range_key          = "PublishDate"
    projection_type    = "INCLUDE"
    non_key_attributes = ["Category", "Slug"]
  }

  local_secondary_index {
    name            = "PublishDateIndex"
    range_key       = "PublishDate"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "tag_ref_table" {
  name                        = "${var.global_variables.prefix}-tag-ref-table"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "Category"
  range_key                   = "Value"
  deletion_protection_enabled = var.global_variables.is_production

  attribute {
    name = "Category"
    type = "S"
  }

  attribute {
    name = "Value"
    type = "S"
  }

  on_demand_throughput {
    max_read_request_units  = var.tag_ref_table_max_read_request_units
    max_write_request_units = var.tag_ref_table_max_write_request_units
  }
}