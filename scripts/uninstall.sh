#!/bin/bash

aws configure --profile default <<EOF
$AWS_ACCESS_KEY_ID
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
text
EOF

aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION --profile default

kubectl config use-context $EKS_ARN

kubectl delete service active-svc
kubectl delete deployment acive-pod

kubectl config delete-context $EKS_ARN

kubectl config unset users.default
kubectl config unset users.$EKS_ARN

kubectl config use-context ""

aws configure --profile default delete

echo "Cleanup completed"
