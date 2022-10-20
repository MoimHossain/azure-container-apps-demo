#!/bin/bash
# This script builds the CognitiveDemo project.
ImageTag="CognitiveDemo"
RegistryName="myregistry.azurecr.io"

echo "Building Images with Tag $ImageTag"

docker build -t $RegistryName/job-listener:$imageTag -f ./JobListener/Dockerfile ./JobListener  



docker push -t $RegistryName/job-listener:$imageTag