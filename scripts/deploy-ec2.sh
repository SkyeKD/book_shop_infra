#!/bin/bash


AWS_REGION="us-west-2"
AMI_ID="ami-00420addee16a7dfb" 
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

# 5️⃣ get EC2 public IP
EC2_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
echo "EC2 Public IP: $EC2_PUBLIC_IP"
echo "$INSTANCE_ID" > ec2-instance-id.env
echo "$EC2_PUBLIC_IP" > ec2_ip.txt

# 6️⃣ install docker
echo "🚀 Installing Docker, Git, and MySQL on EC2..."

# ssh -o StrictHostKeyChecking=no -i ~/.ssh/$KEY_NAME.pem ec2-user@$EC2_PUBLIC_IP << 'EOF'
#     sudo su -c '
#     set -e

#     sudo yum update -y
#     sudo yum install -y git

#     sudo yum install -y docker
#     sudo systemctl start docker
#     sudo systemctl enable docker
#     sudo usermod -aG docker ec2-user
#     sudo usermod -aG docker ec2-user

#     DOCKER_COMPOSE_VERSION="2.22.0"
#     sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#     sudo chmod +x /usr/local/bin/docker-compose
#     newgrp docker
#     sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

#     sudo yum install -y mariadb105

#     echo "✅ Git Version: $(git --version)"
#     echo "✅ Docker Version: $(docker --version)"
#     echo "✅ Docker Compose Version: $(docker-compose --version)"
#     echo "✅ MySQL Version: $(mysql --version)"
#     '
    
# EOF

ssh -o StrictHostKeyChecking=no -i ~/.ssh/$KEY_NAME.pem ec2-user@$EC2_PUBLIC_IP << 'EOF'
    sudo su -c '
    set -e

    echo "📦 Updating system packages..."
    sudo yum update -y

    echo "📦 Installing Git..."
    sudo yum install -y git
    git --version || echo "❌ Git installation failed"

    echo "📦 Installing Docker..."
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user

    echo "📦 Installing Docker Compose..."
    DOCKER_COMPOSE_VERSION="2.22.0"
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    echo "📦 Installing MySQL (MariaDB)..."
    sudo yum install -y mariadb105

    echo "✅ Git Version: $(git --version || echo 'Not installed')"
    echo "✅ Docker Version: $(docker --version || echo 'Not installed')"
    echo "✅ Docker Compose Version: $(docker-compose --version || echo 'Not installed')"
    echo "✅ MySQL Version: $(mysql --version || echo 'Not installed')"
    '
EOF

# 6️⃣ connect SSH
echo "✅ EC2 setup complete!"
echo "To connect via SSH: ssh -i ~/.ssh/$KEY_NAME.pem ec2-user@$EC2_PUBLIC_IP"