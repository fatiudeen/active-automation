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

  ## build and push server to ecr

  #set env
  export ECR_REPOSITORY_URL= $(terraform output ecr_repository_url)
  export AWS_REGION="us-esat-1"
  export DOCKERFILE_PATH="./server/"

  chmod u+x  ./scripts/build_and_push.sh
  ./scripts/build_and_push.sh

  ## deploy to k8s using helm

  #set env
  export DEPL_PATH="./k8s/"
  export AWS_ACCESS_KEY_ID=$aws_access_key
  export AWS_SECRET_ACCESS_KEY=$aws_secret_key
  export CLUSTER_NAME=$(terraform output cluster_name)
  export EKS_ARN=$(terraform output eks_arn)
  export IMAGE_URI="$ECR_REPOSITORY_URL:latest"

  chmod u+x  ./scripts/install.sh
  ./scripts/install.sh

elif [ "$1" = "clean" ]; then
  if [ -f "../plan.tfstate" ]; then
    chmod u+x  ./scripts/uninstall.sh
    ./scripts/uninstall.sh
    terraform destroy -state="./terraform.tfstate"
    # rm -f "../plan.tfstate"
  fi
else
  echo "Invalid argument. Use 'deploy' or 'clean'."
  exit 1
fi
