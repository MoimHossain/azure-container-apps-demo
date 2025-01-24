#!/bin/bash
COMMITHASH=$1
RESOURCE_GROUP=$2
CONTAINER_APP=$3

REVISION="${CONTAINER_APP}--${COMMITHASH:0:10}"

echo "Checking health of $REVISION"

# Get the FQDN of the specific revision
FQDN=$(az containerapp revision show --name $CONTAINER_APP --resource-group $RESOURCE_GROUP --revision $REVISION --query "properties.fqdn" -o tsv)

echo "FQDN: $FQDN"
echo "Invoking https://$FQDN/health"

status_code=$(curl --write-out %{http_code} --silent --output /dev/null "https://$FQDN/health")

echo "status_code: $status_code"
echo "status_code=$status_code" >> $GITHUB_OUTPUT

# if [[ "$status_code" -ne 200 ]] ; then
#   echo "Site status changed to $status_code" | mail -s "SITE STATUS CHECKER" "my_email@email.com" -r "STATUS_CHECKER"
# else
#   exit 0
# fi