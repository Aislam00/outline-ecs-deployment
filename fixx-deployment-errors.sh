#!/bin/bash

# Fix deployment errors
# Run this from your terraform directory

echo "🔧 FIXING DEPLOYMENT ERRORS"
echo "=========================="

# Fix 1: ElastiCache Parameter Group - Use correct Redis family
echo "📝 Fixing ElastiCache parameter group family..."
sed -i '' 's/family = "redis7.x"/family = "redis6.x"/g' modules/elasticache/main.tf

# Fix 2: Ensure we're using the correct region
echo "📝 Checking AWS region..."
aws configure get region

echo ""
echo "🚨 REGION ISSUE DETECTED!"
echo "Your infrastructure is deploying to us-east-1 but you mentioned eu-west-2"
echo ""
echo "Please choose one:"
echo "1) Keep everything in us-east-1 (cheaper, closer to Outline's CDN)"
echo "2) Move everything to eu-west-2 (closer to you if you're in Europe)"
echo ""
read -p "Enter choice (1 or 2): " choice

if [ "$choice" = "2" ]; then
    echo "📝 Updating region to eu-west-2..."
    # Update terraform.tfvars
    sed -i '' 's/aws_region.*=.*"us-east-1"/aws_region = "eu-west-2"/g' terraform.tfvars
    echo "✅ Updated terraform.tfvars to use eu-west-2"
    echo ""
    echo "⚠️  You also need to:"
    echo "1. Update your AWS CLI: aws configure set region eu-west-2"
    echo "2. Re-run terraform init to update providers"
else
    echo "✅ Keeping us-east-1 region"
fi

echo ""
echo "✅ Fixes applied!"
echo ""
echo "🚀 Next steps:"
echo "1. If you changed region, run: terraform init"
echo "2. Run: terraform plan"
echo "3. Run: terraform apply"
