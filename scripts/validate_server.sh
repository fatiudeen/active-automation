#!/bin/bash

pod_name=active-pod

if [ -z "$EXTERNAL_IP" ]; then
  echo "External IP for pod $pod_name not found."
  exit 1
fi

response=$(curl -s $EXTERNAL_IP:5000/automate)  

if [ -z "$response" ]; then
  echo "Failed to access the test endpoint."
  exit 1
fi

echo $response
