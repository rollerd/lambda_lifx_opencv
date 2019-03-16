variable "s3_bucket" {
  description = "s3 bucket where lambda code lives"
}

variable "s3_bucketpics_arn" {
  description = "s3 bucket arn for pictures"
}

variable "s3_bucketpics_id" {
  description = "ID of pics bucket"
}

variable "s3_key" {
  description = "s3 object of lambda code"
}

variable "function_name" {
  description = "name of lambda function"
}

variable "handler" {
  description = "function handler entrypoint" 
}

variable "description" {
  description = "description of lambda function"
}

variable "layers" {
  type = "list"
  description = "list of layer arns to attach to function"
}

variable "runtime" {
  description = "runtime for function"
}

variable "memory_size" {
  description = "memory size in mb for function"
}

variable "timeout" {
  description = "function timeout limit in secs"
}
