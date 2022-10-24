#!/bin/bash

echo "Starting script...Commit Hash received $COMMITHASH and file name $FileName"
az config set extension.use_dynamic_install=yes_without_prompt
az extension add -n containerapp

previd=$(az containerapp revision list -n xeniel-frontend -g xeniel --query '[0].name')

#prevNameWithoutQuites=$(echo $previd | tr -d "\"")
echo 'Previous revision name: ' $previd

az containerapp revision deactivate -g xeniel --revision "xeniel-frontend--013f60ae44"