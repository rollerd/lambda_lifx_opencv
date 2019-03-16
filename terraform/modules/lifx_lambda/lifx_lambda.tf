resource "aws_iam_role" "lifx_lambda" {
  name = "lifx_lambda_role"
  
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

resource "aws_iam_role_policy" "lifx_lambda" {
  name = "lifx_lambda_policy"
  role = "${aws_iam_role.lifx_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {"Effect": "Allow", "Action": ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"], "Resource": "*"},
    {"Effect": "Allow", "Action": ["lambda:List*", "lambda:Get*", "lambda:InvokeFunction"], "Resource": "arn:aws:lambda:*:*:function:*"},
    {"Effect": "Allow", "Action": ["sqs:ChangeMessageVisibility", "sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"], "Resource": "${var.rgb_sqs_arn}" }
  ]
}
EOF
}

resource "aws_lambda_event_source_mapping" "lambda_trigger" {
  event_source_arn = "${var.rgb_sqs_arn}"
  function_name    = "${aws_lambda_alias.lifx_latest.arn}"
}

resource "aws_lambda_alias" "lifx_latest" {
  name = "lambda_lifx_latest_alias"
  description = "alias for lambda s3 lifx function"
  function_name = "${aws_lambda_function.lifx_lambda.arn}"
  function_version = "$LATEST"
}

resource "aws_lambda_function" "lifx_lambda" {
  s3_bucket = "${var.s3_bucket}"
  s3_key = "${var.s3_key}"
  function_name = "${var.function_name}"
  role = "${aws_iam_role.lifx_lambda.arn}"
  handler = "${var.handler}"
  layers = ["${var.layers}"]
  description = "${var.description}"
  runtime = "${var.runtime}"
  memory_size = "${var.memory_size}"
  timeout = "${var.timeout}"
  environment = {
    variables = {
      LIFX_TOKEN = "${var.lifx_token}"
    }
  }
}
