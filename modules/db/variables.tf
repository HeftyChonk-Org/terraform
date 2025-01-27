variable "global_variables" {
  type = object({
    project = string
    region  = string
    account = number
    prefix  = string
  })
  description = "Global variables for sharing across modules"
}

variable "max_read_request_units" {
  type        = number
  description = "(Required) maximum number of strongly consistent reads consumed per second before DynamoDB returns a ThrottlingException."
}

variable "max_write_request_units" {
  type        = number
  description = "(Required) maximum number of writes consumed per second before DynamoDB returns a ThrottlingException."
}