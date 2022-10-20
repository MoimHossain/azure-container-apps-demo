#!/bin/bash
# This script builds the CognitiveDemo project.
ImageTag=$1
RegistryName=$2

echo "Building Images with Tag $ImageTag and pushing to $RegistryName"

echo "Login to Azure Container Registry"
az acr login --name $RegistryName

echo "Building CognitiveDemo.JobListener application"
docker build -t $RegistryName/job-listener:$ImageTag -f ${PWD}/CognitiveDemo/JobListener/Dockerfile ${PWD}/CognitiveDemo/JobListener  

echo "Building CognitiveDemo.XenielBackend application"
docker build -t $RegistryName/frontend:$ImageTag -f ${PWD}/CognitiveDemo/XenielFrontend/Dockerfile ${PWD}/CognitiveDemo/XenielFrontend  


echo "Pushing images to Azure Container Registry"

docker push $RegistryName/job-listener:$ImageTag
docker push $RegistryName/frontend:$ImageTag