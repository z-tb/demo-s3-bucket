#!/usr/bin/env python3

import boto3
import json
import os
import sys
import datetime
import logging
import time

# Configure logging with global scope for all functions
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    
    # check if the event was triggered by a cloudwatch event
    TODO: doesn't seem to be catching the event
    if event and event.get('source') == 'aws.events':
        logger.info ("Starting the lambda function from CloudWatch! Event: " + json.dumps(event))        
    else:
        logger.info ("starting the lambda function")
    
    # without a bucket to work with, we can't do anything in this lambda
    if os.environ.get('S3_BUCKET_NAME') is None:
        print("S3_BUCKET_NAME is not set")
        sys.exit(1)

    # get the name of the s3 bucket from the environment
    mybucket = os.environ.get('S3_BUCKET_NAME')

    # get a list of s3 buckets in the account
    s3 = boto3.client('s3')
    buckets = s3.list_buckets()
    
    # print the name of the s3 bucket retreived
    mybucket = buckets['Buckets'][0]['Name']

    # create a file prefixed withe the current time and upload it to the s3 bucket using am/pm
    current_time = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S%p")
    src_file = current_time + ".txt"
    s3.put_object(Body=f"Hello from {mybucket} - current time is {current_time}" , Bucket=mybucket, Key=src_file)
    

if os.environ.get('DEBUG_MODE') == 'true':
    lambda_handler(event=None, context=None)