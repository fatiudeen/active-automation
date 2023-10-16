#!/bin/bash

TF_DIR="./infra"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [deploy|clean]"
  exit 1
fi

if [ -z "$aws_access_key" ] || [ -z "$aws_secret_key" ]; then
  echo "AWS credentials (aws_access_key and aws_secret_key) are missing. Please provide them."
  exit 1
fi

# Check for AWS CLI
if ! command -v aws &>/dev/null; then
  echo "AWS CLI is not installed. Please install it before running this script."
  exit 1
fi

# Check for kubectl
if ! command -v kubectl &>/dev/null; then
  echo "kubectl is not installed. Please install it before running this script."
  exit 1
fi

# Check for Helm
if ! command -v helm &>/dev/null; then
  echo "Helm is not installed. Please install it before running this script."
  exit 1
fi

# Check for Docker
if ! command -v docker &>/dev/null; then
  echo "Docker is not installed. Please install it before running this script."
  exit 1
fi

cd "$TF_DIR"

if [ "$1" = "deploy" ]; then

  terraform init

  terraform plan -out=../plan.tfstate

  terraform apply "../plan.tfstate" -var="aws_access_key=$aws_access_key" -var="aws_secret_key=aws_secret_key"
elif [ "$1" = "clean" ]; then

  if [ -f "../plan.tfstate" ]; then
    terraform destroy -state="../plan.tfstate"

    # rm -f "../plan.tfstate"
  fi
else
  echo "Invalid argument. Use 'deploy' or 'clean'."
  exit 1
fi
