resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = "${var.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.s3_bucketpics_arn}"
	qualifier     = "${var.qualifier}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
#  bucket = "${var.s3_bucketpics_id}"
  bucket = "${var.s3_bucketpics_id}"
  lambda_function {
    lambda_function_arn = "${var.alias_arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "images/"
  }
}
