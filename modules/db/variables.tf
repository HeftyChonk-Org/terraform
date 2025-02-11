variable "global_variables" {
  type = object({
    project       = string
    region        = string
    account       = number
    is_production = bool
    prefix        = string
  })
  description = "Global variables for sharing across modules"
}

variable "blog_table_max_read_request_units" {
  type        = number
  description = "(Required) Maximum number of strongly consistent reads consumed per second for the main table before DynamoDB returns a ThrottlingException."
}

variable "blog_table_max_write_request_units" {
  type        = number
  description = "(Required) Maximum number of writes consumed per second for the main table before DynamoDB returns a ThrottlingException."
}

variable "tag_ref_table_max_read_request_units" {
  type        = number
  description = "(Required) Maximum number of strongly consistent reads consumed per second for the tag reference table before DynamoDB returns a ThrottlingException."
}

variable "tag_ref_table_max_write_request_units" {
  type        = number
  description = "(Required) Maximum number of writes consumed per second for the tag reference table before DynamoDB returns a ThrottlingException."
}