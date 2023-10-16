aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

helm upgrade --install ingress-nginx  stable/nginx-ingres -n ingress-nginx

helm upgrade --install active-depl -f $DEPL_PATH --set image=$IMAGE