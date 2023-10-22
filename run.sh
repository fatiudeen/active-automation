#!/bin/bash

check_command() {
  command -v $1 >/dev/null 2>&1
}

if check_command docker; then
  :
else
  echo "Docker is not installed. Please install docker before continuing."
  exit 1
fi

if check_command terraform; then
  :
else
  echo "Terraform is not installed. Please install Terraform before continuing."
  exit 1
fi

if check_command aws; then
  :
else
  echo "AWS CLI is not installed. Please install the AWS CLI before continuing."
  exit 1
fi

if check_command kubectl; then
  :
else
  echo "kubectl is not installed. Please install kubectl before continuing."
  exit 1
fi

TF_DIR="$PWD/infra"
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

if ([ "$1" = "deploy" ] || [ "$1" = "clean" ]) && ([ -z "$aws_access_key" ] && [ -z "$aws_secret_key" ]); then
  echo "AWS credentials (aws_access_key and aws_secret_key) are missing. Please provide them using --aws_access_key=<value> and --aws_secret_key=<value>"
  exit 1
fi

if ([ "$1" = "deploy" ] || [ "$1" = "clean" ]) && [ -z "$aws_access_key" ]; then
  echo "AWS credentials (aws_access_key) are missing. Please provide it using --aws_access_key=<value>"
  exit 1
fi

if ([ "$1" = "deploy" ] || [ "$1" = "clean" ]) && [ -z "$aws_secret_key" ]; then
  echo "AWS credentials (aws_secret_key) are missing. Please provide it using --aws_secret_key=<value>"
  exit 1
fi


cd "$TF_DIR"

if [ "$1" = "deploy" ]; then
  terraform init || { echo "Terraform init failed"; exit 1; }
  terraform validate || { echo "Terraform validation failed"; exit 1; }
  terraform plan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key" || { echo "Terraform plan failed"; exit 1; }
  terraform apply -auto-approve  -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key" || { echo "Terraform apply failed"; exit 1; }

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

  cd $WORKING_DIR || { echo "Failed to change to working directory"; exit 1; }

  chmod u+x  ./scripts/build_and_push.sh || { echo "Failed to make script executable"; exit 1; }
  ./scripts/build_and_push.sh || { echo "Script failed"; exit 1; }


  cd $WORKING_DIR  || { echo "Failed to change to working directory"; exit 1; }

  chmod u+x  ./scripts/install.sh || { echo "Failed to make script executable"; exit 1; }
  ./scripts/install.sh || { echo "Script failed"; exit 1; }

elif [ "$1" = "clean" ]; then

    cd $TF_DIR


    export AWS_REGION="us-east-1"
    export AWS_ACCESS_KEY_ID=$aws_access_key
    export AWS_SECRET_ACCESS_KEY=$aws_secret_key
    CLUSTER_NAME=$(terraform output cluster_name)
    export CLUSTER_NAME="${CLUSTER_NAME//\"/}"
    EKS_ARN=$(terraform output eks_arn)
    export EKS_ARN="${EKS_ARN//\"/}"

    cd $WORKING_DIR  || { echo "Failed to change to working directory"; exit 1; }

    chmod u+x  ./scripts/uninstall.sh || { echo "Failed to make script executable"; exit 1; }
    ./scripts/uninstall.sh || { echo "Script failed"; exit 1; }

    cd $TF_DIR
    terraform destroy -auto-approve  -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key" || { echo "Terraform destroy failed"; exit 1; }
    echo "Cleanup completed"

elif [ "$1" = "test" ]; then


    CLUSTER_NAME=$(terraform output cluster_name)
    export CLUSTER_NAME="${CLUSTER_NAME//\"/}"

    cd $WORKING_DIR || { echo "Failed to change to working directory"; exit 1; }

    if [ "$2" == "env" ]; then
      echo "Running the environment script..."
      chmod +x ./scripts/validate_enviroment.sh || { echo "Failed to make script executable"; exit 1; }
      ./scripts/validate_enviroment.sh
    elif [ "$2" == "app" ]; then
      echo "Running the application script..."

      chmod +x ./scripts/validate_server.sh || { echo "Failed to make script executable"; exit 1; }
      ./scripts/validate_server.sh
    else
      echo "Invalid argument. Use 'env' or 'app' as the argument after 'test'."
      exit 1
    fi

else
  echo "Invalid argument. Use 'deploy', 'clean' or 'test'."
  exit 1
fi
