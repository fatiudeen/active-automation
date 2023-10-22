#!/bin/bash

AWS_REGION='us-east-1'
CLUSTER_NAME=active-k8s

aws configure --profile default <<EOF
$AWS_ACCESS_KEY_ID
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
text
EOF

aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION --profile default || true

aws ecr-public batch-delete-image --region $AWS_REGION \
    --repository-name active-image \
    --image-ids imageTag=latest || true


kubectl config use-context $EKS_ARN || true

kubectl delete service active-svc || true
kubectl delete deployment acive-pod || true

kubectl config delete-context $EKS_ARN || true

kubectl config unset users.default || true
kubectl config unset users.$EKS_ARN || true

