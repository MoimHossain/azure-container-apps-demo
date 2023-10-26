#!/bin/bash
COMMITHASH=$1

nextRevisionName="xeniel-frontend--${COMMITHASH:0:10}"

echo "Invoking https://$nextRevisionName.politesand-02cd6988.westeurope.azurecontainerapps.io/health"

status_code=$(curl --write-out %{http_code} --silent --output /dev/null "https://$nextRevisionName.politesand-02cd6988.westeurope.azurecontainerapps.io/health")

echo "status_code: $status_code"
echo "status_code=$status_code" >> $GITHUB_OUTPUT

# if [[ "$status_code" -ne 200 ]] ; then
#   echo "Site status changed to $status_code" | mail -s "SITE STATUS CHECKER" "my_email@email.com" -r "STATUS_CHECKER"
# else
#   exit 0
# fi