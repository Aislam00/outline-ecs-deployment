to point the command to a specific state location.
alaminislam@Alamins-MBP terraform % # Generate secret_key (32 characters)
openssl rand -hex 32

# Generate utils_secret (32 characters)
openssl rand -hex 32
zsh: unknown file attribute: 3
272bbbbfcea2e5b999d159d5e4295744b183c9eaf17cb014d2ddf97db65cb295
zsh: unknown file attribute: 3
8f6d0c55020263df87f9cbfb9574bc6a0cf2b18fc9cba5d39b186495af9a3090
alaminislam@Alamins-MBP terraform %#!/bin/bash

# Optimize AWS costs by using single NAT Gateway
# Run this from your repository root

echo "💰 OPTIMIZING AWS COSTS - SINGLE NAT GATEWAY"
echo "============================================"

cd terraform

# Backup the original file
cp modules/vpc/main.tf modules/vpc/main.tf.backup

# Apply cost optimization
echo "📝 Updating VPC module for single NAT Gateway..."

# Replace the NAT Gateway count
sed -i '' 's/count = length(var\.availability_zones)/count = 1/g' modules/vpc/main.tf

# Fix the route table reference to use single NAT Gateway
sed -i '' 's/nat_gateway_id = aws_nat_gateway\.main\[count\.index\]\.id/nat_gateway_id = aws_nat_gateway.main[0].id/g' modules/vpc/main.tf

echo "✅ Cost optimization applied!"
echo ""
echo "💰 COST SAVINGS:"
echo "  Before: ~$135-145/month"
echo "  After:  ~$90-100/month"
echo "  Savings: ~$45/month (NAT Gateway reduction)"
echo ""
echo "⚠️  Trade-off: Reduced availability if single NAT Gateway fails"
echo ""

# Validate the changes
if terraform validate; then
    echo "✅ Configuration is still valid after optimization"
    rm modules/vpc/main.tf.backup
else
    echo "❌ Validation failed, restoring backup..."
    mv modules/vpc/main.tf.backup modules/vpc/main.tf
    exit 1
fi

cd ..
echo "🚀 Ready for deployment!"
