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