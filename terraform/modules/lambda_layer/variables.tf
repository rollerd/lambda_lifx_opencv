variable "s3_bucket" {
  description = "s3 bucket where layer is located"
}

variable "s3_key" {
  description = "s3 object id of layer"
}

variable "layer_name" {
  description = "name of layer"
}

variable "compatible_runtimes" {
  type = "list"
  description = "list of compatible runtimes"
}
