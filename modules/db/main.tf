resource "aws_dynamodb_table" "table" {
  name                        = "${var.global_variables.prefix}-table"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "BlogID"
  range_key                   = "PublishDate"
  deletion_protection_enabled = strcontains(terraform.workspace, "prod") ? true : false

  attribute {
    name = "BlogID"
    type = "S"
  }

  attribute {
    name = "PublishDate"
    type = "S"
  }

  attribute {
    name = "Category"
    type = "S"
  }

  attribute {
    name = "Service"
    type = "S"
  }

  attribute {
    name = "Tool"
    type = "S"
  }

  local_secondary_index {
    name = "CategoryIndex"
    projection_type = "ALL"
    range_key = "Category"
  }

  local_secondary_index {
    name = "ServiceIndex"
    projection_type = "ALL"
    range_key = "Service"
  }

  local_secondary_index {
    name = "ToolIndex"
    projection_type = "ALL"
    range_key = "Tool"
  }

  on_demand_throughput {
    max_read_request_units = var.max_read_request_units
    max_write_request_units = var.max_write_request_units
  }
}