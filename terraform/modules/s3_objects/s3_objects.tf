resource "aws_s3_bucket_object" "object" {
  bucket = "${var.bucket}"
  key = "${var.key}"
  source = "${path.module}/${var.source_file}"
}

output "id" {
  value = "${aws_s3_bucket_object.object.id}"
}

output "key" {
  value = "${aws_s3_bucket_object.object.key}"
}
