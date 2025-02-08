variable "global_variables" {
  type = object({
    project = string
    region  = string
    account = number
    prefix  = string
  })
  description = "Global variables for sharing across modules"
}

variable "blog_table_name" {
  type = string
  description = "DynamoDB blog table name"
}

variable "tag_ref_table_name" {
  type = string
  description = "DynamoDB tag reference table name"
}