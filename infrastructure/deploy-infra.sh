#!/bin/bash

echo "🚀 Deploying TradeStack Infrastructure..."

# Step 1: Terraform
cd terraform
terraform apply -auto-approve

# Step 2: Get IP
EC2_IP=$(terraform output -raw public_ip)
echo "✅ EC2 IP: $EC2_IP"

# Step 3: Update inventory
sed -i "s/[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+/$EC2_IP/" ../ansible/inventory.ini
echo "✅ Updated inventory.ini"

# Step 4: Wait for EC2 to be ready
echo "⏳ Waiting for EC2 to boot..."
sleep 30

# Step 5: Run Ansible
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml

echo "🎉 TradeStack deployed successfully!"
