#!/bin/bash
COMMITHASH=$1
FileName=$2

echo "Starting script...Commit Hash received $COMMITHASH and file name $FileName"
az config set extension.use_dynamic_install=yes_without_prompt
az extension add -n containerapp

nextRevisionName="xeniel-frontend--${COMMITHASH:0:10}"
previousRevisionName=$(az containerapp revision list -n xeniel-frontend -g xeniel --query '[0].name')

prevNameWithoutQuites=$(echo $previousRevisionName | tr -d "\"")        # using sed echo $pname | sed "s/\"//g"
echo 'Previous revision name: ' $prevNameWithoutQuites
echo 'Next revision name: ' $nextRevisionName

sed -i "s/PREV/$prevNameWithoutQuites/g" ${PWD}/Infrastructure/$FileName.bicep 
sed -i "s/NEXT/$nextRevisionName/g" ${PWD}/Infrastructure/$FileName.bicep 


cat ${PWD}/Infrastructure/$FileName.bicep