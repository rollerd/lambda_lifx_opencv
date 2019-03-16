variable "name" {
  description = "S3 bucket name to create"
}

variable "acl" {
  description = "acl to apply to bucket"
}

variable "tags" {
  type = "map"
  description = "tags to apply to resource"
}
