#!/bin/bash
COMMITHASH=$1

nextRevisionName="xeniel-frontend--${COMMITHASH:0:10}"

status_code=$(curl --write-out %{http_code} --silent --output /dev/null "https://$nextRevisionName.jollytree-a241632e.westeurope.azurecontainerapps.io/health")

echo "status_code: $status_code"