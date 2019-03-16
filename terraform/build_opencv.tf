variable "lambda_bucket_name" {
  default = "pycvlambda2"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

module "s3_bucket_lambda" {
  source = "modules/s3"
  name   = "${var.lambda_bucket_name}"
  acl    = "private"

  tags {
    Name = "${var.lambda_bucket_name}"
  }
}

module "amzn_ec2" {
  source         = "modules/ec2"
  ami            = "ami-0ff8a91507f77f867"
  instance_type  = "t2.micro"
  s3_bucket_arn  = "${module.s3_bucket_lambda.arn}"
  s3_bucket_name = "${module.s3_bucket_lambda.id}"
}
