output "blog_table_name" {
  description = "DynamoDB blog table name"
  value       = aws_dynamodb_table.blog_table.name
}

output "tag_ref_table_name" {
  description = "DynamoDB tag reference table name"
  value       = aws_dynamodb_table.tag_ref_table.name
}