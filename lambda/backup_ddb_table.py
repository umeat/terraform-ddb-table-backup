from __future__ import print_function

import os
import boto3
import json

def lambda_handler(event, context):
    ''' Simply gets all items from a DDB table and stores them in an S3 Bucket 
    as a JSON formatted list.
    '''
    ddb_table_name = os.environ['ddb_table_name']
    ddb_backup_bucket = os.environ['ddb_backup_bucket']

    ddb_items = get_all_items(ddb_table_name)

    s3_client = boto3.client('s3')
    s3_client.put_object(
        Bucket=ddb_backup_bucket,
        Key='{}-backup.json'.format(ddb_table_name),
        Body=json.dumps(ddb_items))


def get_all_items(ddb_table):
    """ Paginates through all items in a given DDB table and returns as list
    """
    ddb_client = boto3.client('dynamodb')
    paginator = ddb_client.get_paginator('scan')
    page_iterator = paginator.paginate(
        TableName=ddb_table, Select='ALL_ATTRIBUTES')

    items = []
    for page in page_iterator:
        items += [item for item in page['Items']]

    return items
