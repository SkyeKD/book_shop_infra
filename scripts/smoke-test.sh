#!/bin/bash


# BACKEND_URL="http://$EC2_PUBLIC_IP:8800/books"
# FRONTEND_URL="http://$EC2_PUBLIC_IP:3000"

BACKEND_URL="http://localhost:8800/books"
FRONTEND_URL="http://localhost:3000"


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