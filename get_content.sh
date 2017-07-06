
URL="$1/prod/content"

TABLE_NAME="event-content-$2"

curl -H "Content-Type: application/x-amz-json-1.1" -X POST -d "{ \"AttributesToGet\": [ \"EventId\", \"CreateTime\" ], \"ReturnConsumedCapacity\": \"TOTAL\", \"TableName\": \"$TABLE_NAME\" }" $URL

