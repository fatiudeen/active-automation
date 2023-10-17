#!/bin/bash

export AWS_DEFAULT_REGION=us-west-1 

eks_cluster_name=$CLUSTER_NAME 
eks_status=$(aws eks describe-cluster --name $eks_cluster_name --query 'cluster.status' --output text 2>/dev/null)

if [ -z "$eks_status" ]; then
  echo "EKS cluster $eks_cluster_name not found."
  exit 1
fi

if [ "$eks_status" == "ACTIVE" ]; then
  echo "EKS cluster $eks_cluster_name is provisioned and in an ACTIVE state."
else
  echo "EKS cluster $eks_cluster_name is provisioned but not in an ACTIVE state."
  exit 1
fi
