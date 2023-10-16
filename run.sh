#!/bin/bash

TF_DIR="./infra"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 [deploy|clean] [--aws_access_key=<ACCESS_KEY> --aws_secret_key=<SECRET_KEY>]"
  exit 1
fi

# Default values for AWS credentials
aws_access_key=""
aws_secret_key=""

for arg in "$@"; do
  case "$arg" in
    --aws_access_key=*)
      aws_access_key="${arg#*=}"
      ;;
    --aws_secret_key=*)
      aws_secret_key="${arg#*=}"
      ;;
  esac
done

if [ "$1" = "deploy" ] && ([ -z "$aws_access_key" ] && [ -z "$aws_secret_key" ]); then
  echo "AWS credentials (aws_access_key and aws_secret_key) are missing. Please provide them using --aws_access_key=<value> and --aws_secret_key=<value>"
  exit 1
fi

if [ "$1" = "deploy" ] && [ -z "$aws_access_key" ]; then
  echo "AWS credentials (aws_access_key) are missing. Please provide it using --aws_access_key=<value>"
  exit 1
fi

if [ "$1" = "deploy" ] && [ -z "$aws_secret_key" ]; then
  echo "AWS credentials (aws_secret_key) are missing. Please provide it using --aws_secret_key=<value>"
  exit 1
fi


cd "$TF_DIR"

if [ "$1" = "deploy" ]; then
  terraform init
  terraform validate
  terraform plan -out=../plan.tfstate -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"
  terraform apply "../plan.tfstate"
elif [ "$1" = "clean" ]; then
  if [ -f "../plan.tfstate" ]; then
    terraform destroy -state="./terraform.tfstate"
    # rm -f "../plan.tfstate"
  fi
else
  echo "Invalid argument. Use 'deploy' or 'clean'."
  exit 1
fi
