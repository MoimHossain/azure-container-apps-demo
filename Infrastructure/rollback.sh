#!/bin/bash
COMMITHASH=$1

echo "Starting script...Commit Hash received $COMMITHASH "
az config set extension.use_dynamic_install=yes_without_prompt
az extension add -n containerapp

nextRevisionName="xeniel-frontend--${COMMITHASH:0:10}"
previousRevisionName=$(az containerapp revision list -n xeniel-frontend -g xeniel --query '[0].name')

prevNameWithoutQuites=$(echo $previousRevisionName | tr -d "\"")        # using sed echo $pname | sed "s/\"//g"
echo 'Previous revision name: ' $prevNameWithoutQuites
echo 'Next revision name: ' $nextRevisionName


echo "Swapping lable latest to the $prevNameWithoutQuites revision"
az containerapp revision label add -g xeniel --label latest --revision $prevNameWithoutQuites -y

echo "Deactovating the $nextRevisionName revision"
az containerapp revision deactivate -g xeniel --revision $nextRevisionName