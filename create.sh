#!/bin/bash

APP_ENV="$1"

aws cloudformation create-stack --stack-name mb-bootstrap-$APP_ENV --template-body file://ops/cfn/bootstrap.cfn.yml

aws cloudformation wait stack-create-complete --stack-name mb-bootstrap-$APP_ENV

BOOTSTRAP_BUCKET=$(aws cloudformation describe-stacks --stack-name mb-bootstrap-$APP_ENV --query 'Stacks[0].Outputs[0].OutputValue' | tr -d '"')

echo "stack created mb-bootstrap-$APP_ENV - bucket: $BOOTSTRAP_BUCKET"

aws cloudformation create-stack --stack-name mb-vpc-$APP_ENV --template-body file://ops/cfn/vpc.cfn.yml

aws cloudformation wait stack-create-complete --stack-name mb-vpc-$APP_ENV

aws cloudformation create-stack --stack-name mb-db-$APP_ENV --template-body file://ops/cfn/db.cfn.yml --parameters ParameterKey=AppEnvironmentName,ParameterValue=$APP_ENV

aws cloudformation wait stack-create-complete --stack-name mb-db-$APP_ENV

aws cloudformation create-stack --stack-name mb-ci-$APP_ENV --template-body file://ops/cfn/ci.cfn.yml

aws cloudformation wait stack-create-complete --stack-name mb-ci-$APP_ENV

LAMBDA_BUCKET=$(aws cloudformation describe-stacks --stack-name mb-ci-$APP_ENV --query 'Stacks[0].Outputs[0].OutputValue' | tr -d '"')

zip -j vote_update.zip app/vote_update.py
aws s3 cp vote_update.zip s3://$LAMBDA_BUCKET

zip -j kinesis_analytics.zip ops/cfn/custom/resources/kinesis_analytics.py
aws s3 cp kinesis_analytics.zip s3://$BOOTSTRAP_BUCKET

aws cloudformation create-stack --stack-name mb-kinesis-$APP_ENV --template-body file://ops/cfn/kinesis.cfn.yml --capabilities CAPABILITY_NAMED_IAM \
  --parameters ParameterKey=AppEnvironmentName,ParameterValue=$APP_ENV ParameterKey=CiStackName,ParameterValue=mb-ci-$APP_ENV ParameterKey=DbStackName,ParameterValue=mb-db-$APP_ENV

aws cloudformation wait stack-create-complete --stack-name mb-kinesis-$APP_ENV

aws cloudformation create-stack --stack-name mb-api-$APP_ENV --template-body file://ops/cfn/api.cfn.yml --capabilities CAPABILITY_NAMED_IAM \
  --parameters ParameterKey=AppEnvironmentName,ParameterValue=$APP_ENV ParameterKey=KinesisStackName,ParameterValue=mb-kinesis-$APP_ENV \
  ParameterKey=DbStackName,ParameterValue=mb-db-$APP_ENV

aws cloudformation wait stack-create-complete --stack-name mb-api-$APP_ENV

zip -j elastic_transcoder_job_complete.zip app/elastic_transcoder_job_complete.py
aws s3 cp elastic_transcoder_job_complete.zip s3://$LAMBDA_BUCKET

aws cloudformation create-stack --stack-name mb-media-$APP_ENV --template-body file://ops/cfn/media.cfn.yml --capabilities CAPABILITY_NAMED_IAM \
  --parameters ParameterKey=AppEnvironmentName,ParameterValue=$APP_ENV ParameterKey=CiStackName,ParameterValue=mb-ci-$APP_ENV ParameterKey=DbStackName,ParameterValue=mb-db-$APP_ENV

aws cloudformation wait stack-create-complete --stack-name mb-media-$APP_ENV


