#!/bin/bash

export AWS_DEFAULT_REGION=us-west-1 

eks_status=$(aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.status' --output text 2>/dev/null)

echo ""

if [ -z "$eks_status" ]; then
  kubectl get all --all-namespaces  || {  echo "EKS cluster $CLUSTER_NAME not found."; exit 1; }
fi

if [ "$eks_status" == "ACTIVE" ]; then
  echo "EKS cluster $CLUSTER_NAME is provisioned and in an ACTIVE state."
else
  echo "EKS cluster $CLUSTER_NAME is provisioned but not in an ACTIVE state."
  exit 1
fi
