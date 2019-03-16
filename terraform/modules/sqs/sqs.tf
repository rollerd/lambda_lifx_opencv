resource "aws_sqs_queue" "lifx_sqs" {
  name = "lifx_sqs"
  visibility_timeout_seconds = 40
  message_retention_seconds = 120
  receive_wait_time_seconds = 20
}

resource "aws_lambda_event_source_mapping" "lambda_trigger" {
  event_source_arn = "${aws_sqs_queue.lifx_sqs.arn}"
  function_name    = "${var.trigger_function_name}"
}

output "arn" {
  value = "${aws_sqs_queue.lifx_sqs.arn}"
}

output "id" {
  value = "${aws_sqs_queue.lifx_sqs.id}"
}
