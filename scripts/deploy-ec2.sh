#!/bin/bash


AWS_REGION="us-west-2"
AMI_ID="ami-021c478d943abe2da" 
# amazon linux 2023 arm
# INSTANCE_TYPE="t3.micro"
INSTANCE_TYPE="t4g.micro"
KEY_NAME="bookshop-key"
SECURITY_GROUP_ID="sg-035d78de7367db290"

# 3️⃣ create EC2 instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bookshop-ec2}]' \
    --query "Instances[0].InstanceId" \
    --output text)

echo "EC2 Instance Created: $INSTANCE_ID"


aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "EC2 Instance is running."
sleep 10

# 5️⃣ get EC2 public IP
EC2_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
echo "EC2 Public IP: $EC2_PUBLIC_IP"
echo "$INSTANCE_ID" > ec2-instance-id.env
echo "$EC2_PUBLIC_IP" > ec2_ip.txt

chmod 400 ~/.ssh/bookshop-key.pem
echo "🚀 Checking SSH Key..."
ls -lah ~/.ssh/



# ssh -o StrictHostKeyChecking=no -i ~/.ssh/bookshop-key.pem ec2-user@$EC2_PUBLIC_IP << EOF
#   set -e

#   echo "📦 Updating system packages..."
#   sudo dnf install -y curl
#   sudo dnf makecache --refresh
#   sudo dnf update -y

#   echo "📦 Installing Git..."
#   sudo dnf install -y git
#   git --version || echo "❌ Git installation failed"

#   echo "📦 Installing Docker..."
#   sudo dnf install -y docker
#   sudo systemctl start docker
#   sudo systemctl enable docker
#   sudo usermod -aG docker ec2-user

#   echo "📦 Installing Docker Compose (manual method)..."

#   sudo -i bash << EOF
#     curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#     chmod +x /usr/local/bin/docker-compose
#     sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
#   EOF
#   echo "📦 Installing MySQL ..."
#   sudo dnf install -y mariadb105

#   echo "✅ Git Version: $(git --version || echo '❌ Git installation failed!')"
#   echo "✅ Docker Version: $(docker --version || echo '❌ Docker installation failed!')"
#   echo "✅ Docker Compose Version: $(docker-compose version || echo '❌ Docker Compose installation failed!')"
#   echo "✅ MySQL Version: $(mysql --version || echo '❌ MySQL installation failed!')"

#   echo "🚀 Setup Complete!"
# EOF

#   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#   sudo chmod +x /usr/local/bin/docker-compose
#   sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# ssh -o StrictHostKeyChecking=no -i ~/.ssh/bookshop-key.pem ec2-user@$EC2_PUBLIC_IP << 'EOF'
#   set -e

#   echo "📦 Updating system packages..."
#   sudo dnf install -y curl
#   sudo dnf makecache --refresh
#   sudo dnf update -y

#   echo "📦 Installing Git..."
#   sudo dnf install -y git
#   git --version || echo "❌ Git installation failed"

#   echo "📦 Installing Docker..."
#   sudo dnf install -y docker
#   sudo systemctl start docker
#   sudo systemctl enable docker
#   sudo usermod -aG docker ec2-user

#   echo "📦 Installing Docker Compose (manual method)..."

#   # 下载 Docker Compose 最新版本
#   DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | cut -d '"' -f 4)
#   sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

#   # 确保 `docker-compose` 可执行
#   sudo chmod +x /usr/local/bin/docker-compose

#   # 软链接，确保 `docker compose` 命令可用
#   sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

#   # 确保 Docker Compose 插件可用
#   sudo dnf install -y docker-compose-plugin || echo "⚠️ Failed to install docker-compose-plugin"

#   echo "📦 Installing MySQL ..."
#   sudo dnf install -y mariadb105

#   echo "✅ Git Version: $(git --version || echo '❌ Git installation failed!')"
#   echo "✅ Docker Version: $(docker --version || echo '❌ Docker installation failed!')"
#   echo "✅ Docker Compose Version: $(docker compose version || echo '❌ Docker Compose installation failed!')"
#   echo "✅ MySQL Version: $(mysql --version || echo '❌ MySQL installation failed!')"

#   echo "🚀 Setup Complete!"
# EOF

ssh -o StrictHostKeyChecking=no -i ~/.ssh/bookshop-key.pem ec2-user@$EC2_PUBLIC_IP << EOF
  set -e

  echo "📦 Updating system packages..."
  sudo dnf clean all
  sudo dnf makecache --refresh
  sudo dnf update -y --allowerasing || echo "⚠️ System update failed"

  echo "📦 Handling curl installation..."
  if rpm -q curl; then
    sudo dnf swap -y curl curl-minimal || echo "⚠️ Failed to swap curl with curl-minimal"
  else
    sudo dnf install -y curl-minimal || echo "⚠️ Failed to install curl-minimal"
  fi

  echo "📦 Installing Git..."
  sudo dnf install -y git || echo "⚠️ Git installation failed"
  git --version || echo "❌ Git installation verification failed"

  echo "📦 Installing MySQL (MariaDB 10.5)..."
  sudo dnf install -y mariadb105

  echo "✅ Git Version: \$(git --version || echo '❌ Git installation failed!')"
  echo "✅ MySQL Version: \$(mysql --version || echo '❌ MySQL installation failed!')"

  echo "🚀 Setup Complete!"
EOF

# 6️⃣ connect SSH
echo "✅ EC2 setup complete!"
echo "To connect via SSH: ssh -i ~/.ssh/$KEY_NAME.pem ec2-user@$EC2_PUBLIC_IP"