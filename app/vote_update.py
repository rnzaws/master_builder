import boto3
import base64
import json
import os

client = boto3.resource('dynamodb')
table_name =  os.environ['DB_TABLE_NAME']

def handler(event, context):

    vote_table = client.Table(table_name)

    for record in event['Records']:
        payload = json.loads(base64.b64decode(record['kinesis']['data']))

        response = vote_table.update_item(
            Key={
                'EventId': payload['EVENTID'],
            },
            UpdateExpression="set YeaCount = if_not_exists(YeaCount, :start) + :yea, NayCount = if_not_exists(NayCount, :start) + :nay",
            ExpressionAttributeValues={
                ':yea': payload['YEA_COUNT'],
                ':nay': payload['NAY_COUNT'],
                ':start': 0,
            },
            ReturnValues="NONE"
        )

        print("response: " + str(response))

    return 'Successfully processed {} records.'.format(len(event['Records']))
