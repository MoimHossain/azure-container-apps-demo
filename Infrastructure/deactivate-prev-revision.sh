#!/bin/bash

az config set extension.use_dynamic_install=yes_without_prompt
az extension add -n containerapp

previd=$(az containerapp revision list -n xeniel-frontend -g xeniel --query '[0].name')

prevNameWithoutQuites=$(echo $previd | tr -d "\"")
echo 'Previous revision name: ' $prevNameWithoutQuites

az containerapp revision deactivate -g xeniel --revision $prevNameWithoutQuites