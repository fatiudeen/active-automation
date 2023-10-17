#!/bin/bash

TF_DIR="./infra"
WORKING_DIR=$PWD

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 [deploy|clean|test] [--aws_access_key=<ACCESS_KEY> --aws_secret_key=<SECRET_KEY>]"
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
  terraform plan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"
  terraform apply -auto-approve

  #set env
  ECR_REPOSITORY_URL=$(terraform output ecr_repository_url)
  export ECR_REPOSITORY_URL="${ECR_REPOSITORY_URL//\"/}"
  export AWS_REGION="us-east-1"
  export DOCKERFILE_PATH="./server/"
  export DEPL_PATH="./k8s/"
  export AWS_ACCESS_KEY_ID=$aws_access_key
  export AWS_SECRET_ACCESS_KEY=$aws_secret_key
  CLUSTER_NAME=$(terraform output cluster_name)
  export CLUSTER_NAME="${CLUSTER_NAME//\"/}"
  EKS_ARN=$(terraform output eks_arn)
  export EKS_ARN="${EKS_ARN//\"/}"
  export IMAGE_URI="$ECR_REPOSITORY_URL:latest"
  AWS_ACCOUNT_ID=$(terraform output account_id)
  export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID//\"/}"

  ## build and push server to ecr

  cd $WORKING_DIR

  chmod u+x  ./scripts/build_and_push.sh
  ./scripts/build_and_push.sh

  ## deploy to k8s using helm

  cd $WORKING_DIR

  chmod u+x  ./scripts/install.sh
  ./scripts/install.sh

elif [ "$1" = "clean" ]; then
    chmod u+x  ./scripts/uninstall.sh
    ./scripts/uninstall.sh
    terraform destroy 
elif [ "$1" = "test" ]; then


    CLUSTER_NAME=$(terraform output cluster_name)
    export CLUSTER_NAME="${CLUSTER_NAME//\"/}"

    cd $WORKING_DIR

    if [ "$2" == "env" ]; then
      echo "Running the environment script..."
      chmod +x ./scripts/validate_enviroment.sh
      ./scripts/validate_enviroment.sh
    elif [ "$2" == "app" ]; then
      echo "Running the application script..."
      chmod +x ./scripts/validate_server.sh
      ./scripts/validate_server.sh
    else
      echo "Invalid argument. Use 'env' or 'app' as the argument after 'test'."
      exit 1
    fi

else
  echo "Invalid argument. Use 'deploy' or 'clean'."
  exit 1
fi
