resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name}"
  acl = "${var.acl}"
  force_destroy = true

  tags = "${var.tags}"
}

output "id" {
  value = "${aws_s3_bucket.bucket.id}"
}

output "arn" {
  value = "${aws_s3_bucket.bucket.arn}"
}
