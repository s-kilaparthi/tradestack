#!/bin/bash

set -e  # Stop on any error

echo "🚀 Deploying TradeStack Infrastructure..."
echo "================================================"

# Step 1: Terraform
echo "📦 Creating AWS Infrastructure with Terraform..."
cd infrastructure/terraform
terraform init
terraform apply -auto-approve

# Step 2: Get IP
EC2_IP=$(terraform output -raw public_ip)
echo "✅ EC2 IP: $EC2_IP"

# Step 3: Update inventory
echo "📝 Updating Ansible inventory..."
if grep -q "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" ../ansible/inventory.ini; then
    sed -i "s/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+/$EC2_IP/" ../ansible/inventory.ini
else
    sed -i "s/\[tradestack_servers\]/[tradestack_servers]\n$EC2_IP ansible_user=ubuntu ansible_ssh_private_key_file=~\/karthik-devops-key.pem/" ../ansible/inventory.ini
fi
echo "✅ Updated inventory.ini with $EC2_IP"

# Step 4: Wait for EC2 to be ready
echo "⏳ Waiting for EC2 to boot (60 seconds)..."
sleep 60

# Step 5: Run Ansible
echo "⚙️ Configuring server with Ansible..."
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass

echo "================================================"
echo "🎉 TradeStack deployed successfully!"
echo "📊 Grafana Dashboard: http://$EC2_IP:3000"
echo "📈 Prometheus: http://$EC2_IP:9090"
echo "================================================"
