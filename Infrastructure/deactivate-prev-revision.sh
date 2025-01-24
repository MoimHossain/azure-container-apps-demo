#!/bin/bash
RESOURCE_GROUP=$1
CONTAINER_APP=$2

az config set extension.use_dynamic_install=yes_without_prompt
az extension add -n containerapp

previd=$(az containerapp revision list -n $CONTAINER_APP -g $RESOURCE_GROUP --query '[0].name')

prevNameWithoutQuites=$(echo $previd | tr -d "\"")
echo 'Previous revision name: ' $prevNameWithoutQuites

az containerapp revision deactivate -g $RESOURCE_GROUP --revision $prevNameWithoutQuites