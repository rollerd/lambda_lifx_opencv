variable "function_name" {
    description = "name of function to invoke from S3"
}

variable "s3_bucketpics_arn" {
    description = "S3 bucket that lambda should have permission to read"
}

variable "s3_bucketpics_id" {
    description = "S3 bucket that will trigger lambda"
}

variable "qualifier" {
    description = "Lambda alias"
}

variable "alias_arn" {
  description = "ARN of lambda alias"
}
