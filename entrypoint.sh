#!/bin/sh

set -x

if [ $# != 3 ]
then
  echo "Must pass Digital Ocean access token, existing droplet id, and image name slug"
  exit 1
fi

TOKEN=$1
DROPLET=$2
IMAGE=$3

check_progress (){
  ACTION_STATUS=`curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/actions/$ACTION_ID" | jq -r .action.status`
  echo The current action status is $ACTION_STATUS
  if [ "$ACTION_STATUS" = "completed" ]; then
    echo "Completed"
    return 0
  else
    sleep 5
    echo Rebuild not yet complete... 
    check_progress
  fi
}


ACTION_ID=`curl -v -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"type":"rebuild","image":"'$IMAGE'"}' "https://api.digitalocean.com/v2/droplets/$DROPLET/actions" | jq .action.id`


echo Action ID is $ACTION_ID

check_progress
if [ $? -ne 0 ]
then
  check_progress
fi

echo Rebuild of droplet $DROPLET is complete.
return 0

