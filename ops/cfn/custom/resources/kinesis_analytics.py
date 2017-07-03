import httplib
import urlparse
import json
import boto3
import botocore
import time

client = boto3.client('kinesisanalytics')

# https://github.com/RealSalmon/lambda-backed-cloud-formation-kms-encryption/blob/master/lambda_function.py
def send_response(request, response, status=None, reason=None):
    """ Send our response to the pre-signed URL supplied by CloudFormation
    If no ResponseURL is found in the request, there is no place to send a
    response. This may be the case if the supplied event was for testing.
    """

    if status is not None:
        response['Status'] = status

    if reason is not None:
        response['Reason'] = reason

    if 'ResponseURL' in request and request['ResponseURL']:
        url = urlparse.urlparse(request['ResponseURL'])
        body = json.dumps(response)
        https = httplib.HTTPSConnection(url.hostname)
        https.request('PUT', url.path+'?'+url.query, body)

    return response

def create_application(client, props):

    application_code = """
CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (yea_count INTEGER, nay_count INTEGER, eventId VARCHAR(30), process_time TIMESTAMP);
CREATE OR REPLACE PUMP "STREAM_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM" SELECT STREAM SUM("yea"), SUM("nay"), "eventId", ROWTIME as process_time
FROM "SOURCE_SQL_STREAM_001" GROUP BY FLOOR("SOURCE_SQL_STREAM_001".ROWTIME TO SECOND), "eventId";""".replace('\n', ' ')

    return client.create_application(
        ApplicationName = props.get('KinesisAnalyticsVoteAggApplicationName'),
        ApplicationDescription = 'A kinesis analytics app for aggregating votes',
        ApplicationCode = application_code,
        Outputs=[
            {
                'Name': 'DESTINATION_SQL_STREAM',
                'KinesisStreamsOutput': {
                    'ResourceARN': props.get('KinesisStreamAggVoteArn'),
                    'RoleARN': props.get('KinesisAnalyticsAggVotesWriteStreamAnalyticsRoleArn'),
                },
                'DestinationSchema': { 'RecordFormatType': 'JSON' },
            },
        ],
        Inputs=[
            {
                'NamePrefix': 'SOURCE_SQL_STREAM',
                'KinesisStreamsInput': {
                    'ResourceARN': props.get('KinesisStreamRawVoteArn'),
                    'RoleARN': props.get('KinesisAnalyticsRawVotesReadStreamAnalyticsRoleArn'),
                },
                'InputSchema': {
                    'RecordFormat': {
                        'RecordFormatType': 'JSON',
                        'MappingParameters': { 'JSONMappingParameters': { 'RecordRowPath': '$', }, },
                    },
                    'RecordEncoding': 'UTF-8',
                    'RecordColumns': [
                        { 'Name': 'userId', 'SqlType': 'VARCHAR(100)', 'Mapping': '$.userId', },
                        { 'Name': 'eventId', 'SqlType': 'VARCHAR(100)', 'Mapping': '$.eventId', },
                        { 'Name': 'yea', 'SqlType': 'INTEGER', 'Mapping': '$.yea', },
                        { 'Name': 'nay', 'SqlType': 'INTEGER', 'Mapping': '$.nay', },
                    ]
                }
            },
        ],
    )

def find_application(client, application_name):
    try:
        return client.describe_application(ApplicationName = application_name)
    except botocore.exceptions.ClientError as ce:
        if ce.response['Error']['Code'] == 'ResourceNotFoundException':
            return None
        raise ce

def handle_delete(client, application_name):
    response = find_application(client, application_name)
    if response is not None:
        delete_response = client.delete_application(
            ApplicationName = application_name,
            CreateTimestamp = response['ApplicationDetail']['CreateTimestamp'],
        )

def handle_update(client, response, props):
    print('TODO: update')

def handle_create(client, response, props):

    application_name = props.get('KinesisAnalyticsVoteAggApplicationName')

    find_response = find_application(client, application_name)

    # Handle the duplicate request
    if find_response is not None:
        response['Data'] = { 'KinesisAnalyticsAppArn': find_response['ApplicationDetail']['ApplicationARN'] }
        return

    create_response = create_application(client, props)

    response['Data'] = { 'KinesisAnalyticsAppArn': create_response['ApplicationSummary']['ApplicationARN'] }

    input_configurations = []

    while True:
        find_response = find_application(client, application_name)
        if find_response is None:
            time.sleep(1)
            continue

        for input_config in find_response['ApplicationDetail']['InputDescriptions']:
            input_configurations.append({
                'Id': input_config['InputId'],
                'InputStartingPositionConfiguration': { 'InputStartingPosition': 'TRIM_HORIZON' }
            })
        break

    client.start_application(ApplicationName = application_name, InputConfigurations = input_configurations)

def process_request(event, response, props):

    client = boto3.client('kinesisanalytics')

    if event['RequestType'] == 'Create':
        handle_create(client, response, props)
    elif event['RequestType'] == 'Delete':
        handle_delete(client, props.get('KinesisAnalyticsVoteAggApplicationName'))
    elif event['RequestType'] == 'Update':
        handle_update(client, response, props)
    else:
        response['Status'] = 'FAILED'
        response['Reason'] = "Do not know about RequestType: %s" % event['RequestType']

def handler(event, context):

    props = event['ResourceProperties']

    response = {
        'StackId': event['StackId'],
        'RequestId': event['RequestId'],
        'PhysicalResourceId': props.get('PhysicalResourceId'),
        'LogicalResourceId': event['LogicalResourceId'],
        'Status': 'SUCCESS'
    }

    try:
        process_request(event, response, props)
    except Exception as e:
        response['Status'] = 'FAILED'
        response['Reason'] = str(e)

    return send_response(event, response)

