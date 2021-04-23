#!/bin/bash

aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $ecrURL
docker pull $dockerHubImage:latest
docker tag $dockerHubImage $ecrURL:latest
docker push $ecrRepoURL:latest