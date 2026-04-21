#!/bin/sh

result=$(curl -X GET --header "Accept: */*" "https://jsonplaceholder.typicode.com/todos/1" | jq -r '.id')

if [ $result -eq 1 ]
then
   exit 0
else
   exit 1
fi

gcloud secrets versions access version-id --secret="secret-id" --format='get(payload.data)' | tr '_-' '/+' | base64 -d