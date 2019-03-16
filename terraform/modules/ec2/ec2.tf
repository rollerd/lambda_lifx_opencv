data "template_file" "init" {
  template = "${file("${path.module}/user_data.txt")}"
  vars = {
    s3_bucket = "${var.s3_bucket_name}"
  }
}

resource "aws_iam_role" "s3_role" {
  name = "ec2_s3_role"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
    name = "ec2_s3_profile"
    role = "${aws_iam_role.s3_role.name}"
}

resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "ec2_s3_policy"
  role = "${aws_iam_role.s3_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "${var.s3_bucket_arn}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::*"
        }
    ]
}
EOF
}

resource "aws_instance" "ec2" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2_s3_profile.name}"
  user_data = "${data.template_file.init.rendered}"
}
