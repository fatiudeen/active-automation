
aws configure --profile default <<EOF
$AWS_ACCESS_KEY_ID
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
text
EOF

aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION --profile default

kubectl config use-context $EKS_ARN
 

kubectl run acive-pod --image=$IMAGE_URI --port=5000

sleep 30

kubectl expose pod active-pod --type=LoadBalancer --name=active-svc --port=80 --target-port=5000

