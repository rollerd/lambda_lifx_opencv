### AWS LIFX lightbulb color setter

This repo contains the Terraform and Python code for building AWS Lambda functions that can set the color of LIFX bulbs based on the largest percentage KMeans cluster of a picture file.

##### Requirements
- An AWS account
- Python2.7
- Terraform 0.11.x
- LIFX bulb(s) and API token

##### Optional
- A Raspberry Pi with camera module and internet access

##### How it works
An image upload to an S3 bucket triggers a Lambda function that will calculate a set of 3 KMeans clusters based on the most dominant colors in the image. The result is a set of mappings holding the percentages of each of the three colors as well as a list of the RGB values for those colors:

```{'color1':{'rgb':[255,255,255], 'percent': 78}}```

The result is sent to an SQS message queue where a second Lambda function will then receive the message, find the largest percentage color, and call the LIFX API with the RGB value of that color.

##### Usage
- First you must setup your AWS credentials
- Next, you will need to create your Lambda opencv and requests layers by compiling OpenCV against an Amazon Linux image.
- The Terraform and scripts to do this are provided in this repo and can be run by simply cloning the repo and running:

  ```make build_opencv```

    This will take quite a bit of time (~10min) but will create an S3 bucket and upload the zip files containing the packages needed for the Lambda layers and then shutdown the EC2 instance when it's done, so be patient.
    
- Once the EC2 instance has shutdown and there are two zip files in the newly created S3 bucket, you can build the Lambda functions. Just run:

  ```make build_lambda```
  
  After the  Terraform build has completed, you should be able to upload a small image to the picture S3 bucket and within a few seconds, see the color of your LIFX bulb change to match the most dominant cluster color in that image.

- The `raspi_pic.py` script in the `scripts/` directory can be copied to a Raspberry Pi with a camera module and AWS credentials and then used to take and upload pics to S3. 
  
- To destroy, just run:

  ```make destroy_lambda```
  
   ```make destroy_opencv```
   
   ```make clean-all```

