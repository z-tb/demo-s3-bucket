#!/usr/bin/env python3

import boto3
import json
import os
import sys


def lambda_handler(event, context):
    print(event)
    print(context)
    print("Hello, World!")

    if os.environ.get('S3_BUCKET_NAME') is None:
        print("S3_BUCKET_NAME is not set")
        sys.exit(1)

    mybucket = os.environ.get('S3_BUCKET_NAME')

    # get a list of s3 buckets in the account
    s3 = boto3.client('s3')
    buckets = s3.list_buckets()
    
    # print the name of the s3 bucket retreived
    mybucket = buckets['Buckets'][0]['Name']
    print(f"mybucket: {mybucket}")

    # create a file named bucketlist.txt in s3 bucket named mybucket
    s3.put_object(Body=f"Hello from {mybucket}" , Bucket=mybucket, Key='bucketlist.txt')
    

if os.environ.get('DEBUG_MODE') == 'true':
    lambda_handler(event=None, context=None)