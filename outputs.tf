output "blog_table_name" {
  description = "DynamoDB blog table name"
  value       = module.db.blog_table_name
}

output "tag_ref_table_name" {
  description = "DynamoDB tag reference table name"
  value       = module.db.tag_ref_table_name
}

output "api_key_id" {
  description = "API Gateway API Key ID"
  sensitive   = true
  value       = module.api.api_key_id
}

output "app_domain_name" {
  description = "Application domain name"
  value       = module.cdn.app_domain_name
}