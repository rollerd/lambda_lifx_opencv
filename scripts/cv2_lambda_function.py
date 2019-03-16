from sklearn.cluster import KMeans
import cv2
import numpy as np
import boto3
import os
import json

NUMBER_OF_CLUSTERS = 3

# credit to: https://www.pyimagesearch.com/2014/05/26/opencv-python-k-means-color-clustering/
def lambda_handler(event, context):
    s3 = boto3.client("s3")

    image_list = []
  
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
         
        data = s3.get_object(Bucket=bucket_name, Key=key)
        input_image = data['Body'].read()
        nparr = np.fromstring(input_image, np.uint8)

        clusters = NUMBER_OF_CLUSTERS

        # load the image and convert it from BGR to RGB
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        # reshape the image to be a list of pixels
        image = image.reshape((image.shape[0] * image.shape[1], 3))

        # cluster the pixel intensities
        clt = KMeans(n_clusters = clusters)
        clt.fit(image)

        # build a histogram of clusters and then create a figure
        # representing the number of pixels labeled to each color
        # grab the number of different clusters and create a histogram
        # based on the number of pixels assigned to each cluster
        numLabels = np.arange(0, len(np.unique(clt.labels_)) + 1)
        (hist, _) = np.histogram(clt.labels_, bins = numLabels)
     
        # normalize the histogram, such that it sums to one
        hist = hist.astype("float")
        hist /= hist.sum()

        # Create list of color mappings: [{'color1':{'rgb':[255,255,255], 'percent': 78}}, etc]
        color_result = []
        data_map = {}
        count = 0
        for (percent, color) in zip(hist, clt.cluster_centers_):
            data_map['color{0}'.format(count)] = {"percent": int(percent * 100), "rgb": [int(x) for x in color]}
            count += 1
            
        color_result.append(data_map)
        
        if color_result:
            print("Success: ")
            print(color_result)

        image_list.append(color_result)

    # Send color mapping list message to SQS
    sqs = boto3.client('sqs')
    queue_url = os.environ.get('SQS_URL')

    for image in image_list:
        sqs_payload = json.dumps(image)
        response = sqs.send_message(QueueUrl=queue_url, MessageBody=sqs_payload)

    return image_list
