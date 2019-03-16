variable "rgb_sqs_arn" {
  description = "the arn of the rgb sqs queue where messages will be received from"
}

variable "rgb_sqs_url" {
  description = "url of rgb sqs queue"
}

variable "layers" {
  type = "list"
  description = "lambda layer to add to function"
}

variable "s3_bucket" {
  description = "s3 bucket where the lifx lambda code lives"
}

variable "s3_key" {
  description = "s3 object where lambda code lives"
}

variable "function_name" {
  description = "name of the function"
}

variable "handler" {
  description = "lambda function handler"
}

variable "description" {
  description = "description of the lambda function"
}

variable "runtime" {
  description = "runtime for the function"
}

variable "memory_size" {
  description = "how much memory to allocate to the function"
}

variable "timeout" {
  description = "timeout for the function"
}

variable "lifx_token" {
  description = "lifx API token"
}
