variable "global_variables" {
  type = object({
    project = string
    region  = string
    account = number
    prefix  = string
  })
  description = "Global variables for sharing across modules"
}