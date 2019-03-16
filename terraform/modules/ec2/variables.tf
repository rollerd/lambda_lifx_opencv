variable "s3_bucket_arn" {
  description = "bucket to store opencv packages in"
}

variable "s3_bucket_name" {
  description = "name of bucket to allow ec2 to write to"
}

variable "ami" {
  description = "Amazon linux AMI"
}

variable "instance_type" {
  description = "instance type"
  default = "t2.micro"
}

