### AWS LIFX lightbulb color setter

This repo contains the Terraform and Python code for building AWS Lambda functions that can set the color of LIFX lightbulbs based on the most dominant average color in an image.

#### Requirements
- An AWS account
- Python2.7
- Terraform 0.11.x
- LIFX bulb(s) and [API](https://api.developer.lifx.com) token

##### Optional
- A Raspberry Pi with camera module and internet access

#### How it works
An image upload to a specific S3 bucket triggers a Lambda function that will calculate a set of 3 KMeans clusters based on the most dominant colors in the image. The result is a set of mappings holding the percentages of each of the three colors as well as a list of the RGB values for those colors:

```{'color1':{'rgb':[255,255,255], 'percent': 78}}```

The result is sent to an AWS SQS queue where a second Lambda function then receives the message, finds the color with the largest percentage, and calls the LIFX API with the RGB value of that color.

#### Configuration
- You will need to set your AWS credentials such that Terrform can use them. The easiest way is to just create an `~/.aws/credentials` file with the following format:

  ```
  [default]
  aws_access_key_id=<YOUR_KEY_ID>
  aws_secret_access_key=<YOUR_SECRET_KEY>
  ```
- Terraform will ask for your LIFX token when building, or optionally, you may set it as an environment variable before building to save time:
  
  ```
  export TF_VAR_lifx_token=<YOUR_LIFX_TOKEN>
  ```
  
- Because S3 bucket names are unique across an AWS region, you will likely want to change the names of the two buckets that hold the Lambda code and pictures. You can do this by either changing the default values at the top of the `terraform/build_lambda.tf` file, or setting them as environment variables:

  ```
  export TF_VAR_picture_bucket_name=<S3_BUCKET_FOR_PICS>
  export TF_VAR_lambda_bucket_name=<S3_BUCKET_FOR_CODE>
  ```
  > If you plan on using the Raspberry Pi script, you will need to change the `PICTURE_BUCKET_NAME` global var at the top of `scripts/raspi_pic.py` to match the name of your S3 picture bucket.

- If you would like to change the number of KMeans clusters, just change the `NUMBER_OF_CLUSTERS` global variable in `scripts/cv2_lamba_function`. Just be aware that you may also need to change the timeout in the Terraform for the cv2_lambda_function.

#### Usage
1. First, you will need to create your Lambda opencv and requests layers by compiling OpenCV against an Amazon Linux image. The Terraform and build scripts to do this are provided in this repo and can be run by simply cloning the repo and running:

    ```make build_opencv```

      >This will take quite a bit of time (~13min) but will create an S3 bucket and upload the zip files containing the packages needed for the Lambda layers and then shutdown the EC2 instance when it's done, so be patient.
    
2. Once the EC2 instance has shutdown and there are two zip files in the newly created S3 bucket, you can build the Lambda functions. Just run:

    ```make build_lambda```
  
 3. After the Terraform build has completed, you should be able to upload a small image to the newly created S3 picture bucket and within a few seconds, see the color of your LIFX bulb change to match the most dominant cluster color in that image.
  
4. To destroy, just run:

    ```make destroy_lambda```

    ```make destroy_opencv```

    ```make clean-all```

###### Author
David Roller
