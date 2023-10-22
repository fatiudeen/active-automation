#!/bin/bash

pod_name=active-pod

EXTERNAL_IP=$(kubectl get svc active-svc --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$EXTERNAL_IP" ]; then
  echo "External IP for pod $pod_name not found."
  exit 1
fi
echo ""
echo "URI:"
echo "$EXTERNAL_IP/automate"
echo ""
echo "RESPONSE:"
response=$(curl -s $EXTERNAL_IP/automate)  

if [ -z "$response" ]; then
  echo "Failed to access the test endpoint."
  exit 1
fi

echo $response
exit 1
