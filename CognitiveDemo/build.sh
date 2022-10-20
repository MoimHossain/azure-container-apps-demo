#!/bin/bash
# This script builds the CognitiveDemo project.
ImageTag=$1
RegistryName=$2

echo "Building Images with Tag $ImageTag"

docker build -t $RegistryName/job-listener:$ImageTag -f ./JobListener/Dockerfile ./JobListener  



docker push $RegistryName/job-listener:$ImageTag