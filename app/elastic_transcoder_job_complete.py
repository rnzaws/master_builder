import boto3
import base64
import json
import os
import datetime

client = boto3.resource('dynamodb')
table_name =  os.environ['DB_TABLE_NAME']

def handler(event, context):

    content_table = client.Table(table_name)

    for record in event['Records']:

        jsonObj = json.loads(record['Sns']['Message'])
        print(jsonObj['input']['key'])

        rawId = jsonObj['input']['key'].replace(".mp4", "").split("-")

        response = content_table.put_item(
            Item={
                'EventId': rawId[1],
                'CreateTime': datetime.datetime.utcnow().isoformat(),
            }
        )
        print("response: " + str(response))

    return 'Successfully processed {} records.'.format(len(event['Records']))
