#!/bin/bash
COMMITHASH=$1
RESOURCE_GROUP=$2
CONTAINER_APP=$3

echo "Starting script...Commit Hash received $COMMITHASH "
az config set extension.use_dynamic_install=yes_without_prompt
az extension add -n containerapp

nextRevisionName="$CONTAINER_APP--${COMMITHASH:0:10}"
previousRevisionName=$(az containerapp revision list -n $CONTAINER_APP -g $RESOURCE_GROUP --query '[0].name')

prevNameWithoutQuites=$(echo $previousRevisionName | tr -d "\"")        # using sed echo $pname | sed "s/\"//g"
echo 'Previous revision name: ' $prevNameWithoutQuites
echo 'Next revision name: ' $nextRevisionName


echo "Swapping lable latest to the $prevNameWithoutQuites revision"
az containerapp revision label add -g $RESOURCE_GROUP --label latest --revision $prevNameWithoutQuites -y

echo "Deactovating the $nextRevisionName revision"
az containerapp revision deactivate -g $RESOURCE_GROUP --revision $nextRevisionName

echo "Restoring traffic 100 to older revision"
az containerapp ingress traffic set -n $CONTAINER_APP -g $RESOURCE_GROUP --revision-weight $prevNameWithoutQuites=100