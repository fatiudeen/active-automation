
aws configure --profile default <<EOF
$AWS_ACCESS_KEY_ID
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
text
EOF

aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION --profile default

kubectl config use-context $EKS_ARN
 

helm upgrade --install --debug active-depl -f $DEPL_PATH --set image "$IMAGE_URI"