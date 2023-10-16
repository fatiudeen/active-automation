IMAGE_URI="$IMAGE:latest"

aws configure --profile tf-profile <<EOF
$AWS_ACCESS_KEY_ID
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
text
EOF

aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION --profile tf-profile

kubectl config use-context $EKS_ARN

# helm upgrade --install ingress-nginx  oci://registry-1.docker.io/bitnamicharts/nginx-ingress-controller
echo $IMAGE_URI


helm upgrade --install active-depl -f $DEPL_PATH --set image "$IMAGE_URI"