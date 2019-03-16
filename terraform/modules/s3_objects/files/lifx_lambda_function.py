import requests
import json
import os
import boto3

LIFX_TOKEN = os.environ.get('LIFX_TOKEN', None)

def lambda_handler(event, context):
    print("EVENT: {0}".format(event))

    url = "https://api.lifx.com/v1/lights/all/state"
    sqs = boto3.client('sqs')

    records = event['Records']

    for record in records:
        _, _, sqs_svc, region, account_id, queue = record['eventSourceARN'].split(":")
        queue_url = "https://{0}.{1}.amazonaws.com/{2}/{3}".format(sqs_svc, region, account_id, queue)
        receipt_handle = record['receiptHandle']
        
        dominant_color = {}
        sqs_body = json.loads(record['body'])

        for cluster in sqs_body:
            for color in cluster:
                if cluster[color]['percent'] > dominant_color.get('percent', 0):
                    dominant_color['percent'] = cluster[color]['percent']
                    dominant_color['rgb'] = cluster[color]['rgb']

        rgb_string = "rgb:{0}".format(",".join([str(x) for x in dominant_color['rgb']]))

        payload = {"color": rgb_string}
        headers = {"Authorization": "Bearer {0}".format(LIFX_TOKEN)}
        r = requests.put(url=url, data=json.dumps(payload), headers=headers) 

        print("REQUESTS_RESPONSE: {0}".format(r.text))

        response = sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=receipt_handle)
        print("DELETE_MSG_RESPONSE: {0}".format(response))

        message_body = record['body']
        print("MESSAGE_BODY: {0}".format(message_body))
