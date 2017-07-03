#!/bin/bash

URL="$1/prod/votes"

DB_NAME="event-votes-$2"

curl -H "Content-Type: application/x-amz-json-1.1" -X POST -d \
"{ \"ConsistentRead\": false, \"Key\": { \"EventId\" : { \"S\": \"newnewnewtest\" } }, \"ProjectionExpression\": \"NayCount, YeaCount\", \"ReturnConsumedCapacity\": \"TOTAL\", \"TableName\": \"$DB_NAME\" }" $URL


