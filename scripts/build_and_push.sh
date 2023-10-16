#!/bin/bash

IFS="/" read -ra URL <<< "$ECR_REPOSITORY_URL"

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "${URL[0]}"

docker build $DOCKERFILE_PATH -t active-container:latest

docker tag  "active-container:latest" "$ECR_REPOSITORY_URL:latest"

docker push "$ECR_REPOSITORY_URL:latest"
