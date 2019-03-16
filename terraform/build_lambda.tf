variable "lifx_token" {}

variable "picture_bucket_name" {
  default = "pycvlambdapics2"
}

variable "lambda_bucket_name" {
  default = "pycvlambda2"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# Create picture bucket
module "s3_bucket_pics" {
  source = "modules/s3"
  name   = "${var.picture_bucket_name}"
  acl    = "private"

  tags {
    Name = "${var.picture_bucket_name}"
  }
}

# Add Lambda code to S3 bucket
module "s3_object_cv2_lambda" {
  source      = "modules/s3_objects"
  bucket      = "${var.lambda_bucket_name}"
  key         = "cv2_lambda_function.zip"
  source_file = "files/cv2_lambda_function.zip"
}

module "s3_object_lifx_lambda" {
  source      = "modules/s3_objects"
  bucket      = "${var.lambda_bucket_name}"
  key         = "lifx_lambda_function.zip"
  source_file = "files/lifx_lambda_function.zip"
}

module "s3_object_test_pic" {
  source      = "modules/s3_objects"
  bucket      = "${module.s3_bucket_pics.id}"
  key         = "images/test.jpg"
  source_file = "files/red_yellow.jpg"
}

# Add layer code to S3 bucket
module "cv2_lambda_layer" {
  source              = "modules/lambda_layer"
  s3_bucket           = "${var.lambda_bucket_name}"
  s3_key              = "opencv_layer.zip"
  layer_name          = "opencv_layer"
  compatible_runtimes = ["python2.7"]
}

module "requests_lambda_layer" {
  source              = "modules/lambda_layer"
  s3_bucket           = "${var.lambda_bucket_name}"
  s3_key              = "requests_layer.zip"
  layer_name          = "requests_layer"
  compatible_runtimes = ["python2.7"]
}

# Configure S3 Lambda trigger
module "s3_trigger" {
  source = "modules/s3_trigger"
  function_name = "${module.cv2_lambda.function_name}"
  s3_bucketpics_arn = "${module.s3_bucket_pics.arn}"
  s3_bucketpics_id = "${module.s3_bucket_pics.id}"
  qualifier = "${module.cv2_lambda.alias_name}"
  alias_arn = "${module.cv2_lambda.alias_arn}"
}

# Create SQS queue
module "sqs" {
  source = "modules/sqs"
  trigger_function_name = "${module.lifx_lambda.arn}"
}

# Create Lambda functions
module "cv2_lambda" {
  source            = "modules/cv2_lambda"
  s3_bucket         = "${var.lambda_bucket_name}"
  s3_key            = "${module.s3_object_cv2_lambda.id}"
  function_name     = "cv2_lambda"
  handler           = "cv2_lambda_function.lambda_handler"
  description       = "finds kmeans color clusters in image and returns color% and rgb values"
  layers            = ["${module.cv2_lambda_layer.arn}"]
  runtime           = "python2.7"
  memory_size       = 256
  timeout           = 35
  sqs_arn = "${module.sqs.arn}"
  sqs_id = "${module.sqs.id}"
  s3_bucketpics_arn = "${module.s3_bucket_pics.arn}"
}

module "lifx_lambda" {
  source        = "modules/lifx_lambda"
  s3_bucket     = "${var.lambda_bucket_name}"
  s3_key        = "${module.s3_object_lifx_lambda.id}"
  function_name = "lifx_lambda"
  handler       = "lifx_lambda_function.lambda_handler"
  description   = "calls lifx api to set light color"
  layers        = ["${module.requests_lambda_layer.arn}"]
  runtime       = "python2.7"
  memory_size   = 128
  timeout       = 15
  sqs_arn   = "${module.sqs.arn}"
  lifx_token    = "${var.lifx_token}"
}
