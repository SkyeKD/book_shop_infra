#!/bin/bash


# **从 ec2-instance.env 读取 EC2 的公网 IP**
# source ec2-instance.env

# if [ -z "$EC2_PUBLIC_IP" ]; then
#   echo "❌ EC2_PUBLIC_IP is empty! Make sure deploy-ec2.sh was run successfully."
#   exit 1
# fi
EC2_PUBLIC_IP=44.245.208.49

BACKEND_URL="http://$EC2_PUBLIC_IP:8800/books"
FRONTEND_URL="http://$EC2_PUBLIC_IP:3000"


echo "🔍 Testing Backend Health..."
BACKEND_RESPONSE_BODY=$(curl -s $BACKEND_URL)
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BACKEND_URL)

if [[ "$BACKEND_STATUS" -eq 200 && "$BACKEND_RESPONSE_BODY" == *"["* ]]; then
  echo "✅ Backend is UP and returning data"
else
  echo "❌ Backend is DOWN or not returning expected data ($BACKEND_STATUS)"
  exit 1
fi


echo "🔍 Testing Frontend..."
FRONTEND_RESPONSE_BODY=$(curl -s $FRONTEND_URL)
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $FRONTEND_URL)

if [[ "$FRONTEND_STATUS" -eq 200 && "$FRONTEND_RESPONSE_BODY" == *"<!DOCTYPE html>"* ]]; then
  echo "✅ Frontend is UP and serving HTML"
else
  echo "❌ Frontend is DOWN or not serving expected HTML ($FRONTEND_STATUS)"
  exit 1
fi

echo "✅ Smoke Test PASSED!"