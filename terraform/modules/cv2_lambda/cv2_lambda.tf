resource "aws_iam_role" "cv2_lambda" {
  name = "cv2_lambda_role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cv2_lambda" {
  name = "cv2_lambda_policy"
  role = "${aws_iam_role.cv2_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {"Effect": "Allow", "Action": ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"], "Resource": "*"},
    {"Effect": "Allow", "Action": ["lambda:List*", "lambda:Get*", "lambda:InvokeFunction"], "Resource": "arn:aws:lambda:*:*:function:*"},
    {"Effect": "Allow", "Action": ["s3:Get*", "s3:List*"], "Resource": "${var.s3_bucketpics_arn}" },
    {"Effect": "Allow", "Action": ["s3:Get*", "s3:List*"], "Resource": "${var.s3_bucketpics_arn}/*" },
    {"Effect": "Allow", "Action": ["sqs:SendMessage"], "Resource": "${aws_sqs_queue.rgb_sqs.arn}" }
  ]
}
EOF
}

resource "aws_sqs_queue" "rgb_sqs" {
  name = "rgb_sqs"
  visibility_timeout_seconds = 40
  message_retention_seconds = 120
  receive_wait_time_seconds = 20
}

resource "aws_lambda_permission" "with_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cv2_lambda.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.s3_bucketpics_arn}"
	qualifier     = "${aws_lambda_alias.cv2_latest.name}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${var.s3_bucketpics_id}"
  lambda_function {
    lambda_function_arn = "${aws_lambda_alias.cv2_latest.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "images/"
  }
}


resource "aws_lambda_alias" "cv2_latest" {
  name = "cv2_lambda_latest_alias"
  description = "alias for cv2_lambda s3 pycv2 function"
  function_name = "${aws_lambda_function.cv2_lambda.arn}"
  function_version = "$LATEST"
}

resource "aws_lambda_function" "cv2_lambda" {
  s3_bucket = "${var.s3_bucket}"
  s3_key = "${var.s3_key}"
  function_name = "${var.function_name}"
  role = "${aws_iam_role.cv2_lambda.arn}"
  handler = "${var.handler}"
  description = "${var.description}"
  layers = ["${var.layers}"]
  runtime = "${var.runtime}"
  memory_size = "${var.memory_size}"
  timeout = "${var.timeout}"
  environment = {
    variables = {
      SQS_URL = "${aws_sqs_queue.rgb_sqs.id}"
    }
  }
}


output "sqs_arn" {
  value = "${aws_sqs_queue.rgb_sqs.arn}"
}

output "sqs_url" {
  value = "${aws_sqs_queue.rgb_sqs.id}"
}
