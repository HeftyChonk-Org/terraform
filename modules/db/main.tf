resource "aws_dynamodb_table" "table" {
  name                        = "${var.global_variables.prefix}-table"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "LockID"
  deletion_protection_enabled = strcontains(terraform.workspace, "prod") ? false : true

  attribute {
    name = "LockID"
    type = "S"
  }
}