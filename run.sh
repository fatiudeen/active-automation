#!/bin/bash

TF_DIR="./infra"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [deploy|clean]"
  exit 1
fi

cd "$TF_DIR"

if [ "$1" = "deploy" ]; then

  terraform init

  terraform plan -out=../plan.tfstate

  terraform apply "../plan.tfstate"
elif [ "$1" = "clean" ]; then

  if [ -f "../plan.tfstate" ]; then
    terraform destroy -state="../plan.tfstate"

    # rm -f "../plan.tfstate"
  fi
else
  echo "Invalid argument. Use 'deploy' or 'clean'."
  exit 1
fi
