#!/bin/bash

pod_name=active-pod

external_ip=$(kubectl get pod $pod_name -o jsonpath='{.status.hostIP}')

if [ -z "$external_ip" ]; then
  echo "External IP for pod $pod_name not found."
  exit 1
fi

response=$(curl -s $external_ip:80)  

if [ -z "$response" ]; then
  echo "Failed to access the test endpoint."
  exit 1
fi

echo $response
