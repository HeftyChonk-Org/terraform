output "main_table_name" {
  description = "DynamoDB main table name"
  value = aws_dynamodb_table.main_table.name
}

output "tag_ref_table_name" {
  description = "DynamoDB tag reference table name"
  value = aws_dynamodb_table.tag_ref_table.name
}