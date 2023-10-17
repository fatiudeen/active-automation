#!/bin/bash

IFS="/" read -ra URL <<< "$ECR_REPOSITORY_URL"

aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin  public.ecr.aws

docker build $DOCKERFILE_PATH -t active-container-img:latest

docker tag  "active-image:latest" "$ECR_REPOSITORY_URL:latest"

docker push "$ECR_REPOSITORY_URL:latest"
