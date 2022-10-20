#!/bin/bash
# This script builds the CognitiveDemo project.
ImageTag=$1
RegistryName=$2

echo "Building Images with Tag $ImageTag"

az acr login --name RegistryName

docker build -t $RegistryName/job-listener:$ImageTag -f ${PWD}/CognitiveDemo/JobListener/Dockerfile ${PWD}/CognitiveDemo/JobListener  



docker push $RegistryName/job-listener:$ImageTag