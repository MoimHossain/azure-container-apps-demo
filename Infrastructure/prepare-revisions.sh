#!/bin/bash
COMMITHASH=$1

echo "Starting script...Commit Hash received $COMMITHASH"


az config set extension.use_dynamic_install=yes_without_prompt
az extension add -n containerapp

nextRevisionName="xeniel-frontend--${COMMITHASH:0:10}"
previousRevisionName=$(az containerapp revision list -n xeniel-frontend -g xeniel --query '[0].name')

echo 'Previous revision name: ' $previousRevisionName
echo 'Next revision name: ' $nextRevisionName


echo "{AZCAP_PREV_REV}={$previousRevisionName}" >> $GITHUB_ENV
echo "{AZCAP_NEXT_REV}={$nextRevisionName}" >> $GITHUB_ENV
echo "$GITHUB_ENV"
cat $GITHUB_ENV


sed 's/PREV/'$previousRevisionName'/g;s/NEXT/'$nextRevisionName'/g' ${PWD}/Infrastructure/ts.template > ${PWD}/Infrastructure/ts.tmp
sed "s/\"/'/g" ${PWD}/Infrastructure/ts.tmp > ${PWD}/Infrastructure/ts.json
cat ${PWD}/Infrastructure/ts.json