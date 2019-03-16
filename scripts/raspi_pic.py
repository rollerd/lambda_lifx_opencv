#!/bin/env python

# This script takes a picture using the raspberry pi's camera module and uploads it to an AWS S3 bucket
# Set AWS credentials in ~/.aws/credentials and region in ~/.aws/config
import boto3
import subprocess
from datetime import datetime

PICTURE_BUCKET_NAME="pycvlambdapics2"

def capture_image():
    image_name = "image_{0}.jpg".format(datetime.now().strftime("%m%d%H_%M"))
    p = subprocess.call(["raspistill", "-h", "600", "-w", "600", "-o", image_name])

    return image_name


def upload_image(image_name):
    s3 = boto3.client('s3')

    with open(image_name, "rb") as f:
        image = f.read()

    response = s3.put_object(
            Bucket=PICTURE_BUCKET_NAME,
            Key="images/{0}".format(image_name),
            Body=image
            )

    print(response)

if __name__=="__main__":
    image_name = capture_image()
    upload_image(image_name)
