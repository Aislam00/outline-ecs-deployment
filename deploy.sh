#!/bin/bash
# deploy.sh - Complete deployment script for Outline ECS
# Run this script to deploy everything in one go

set -e

echo "🚀 Starting Outline ECS Deployment for aislam00"
echo "📧 Contact: islamadam436@gmail.com"
echo "🌍 Region: eu-west-2"
echo "🔗 Domain: https://tm.integratepro.online"
echo "💰 COST-OPTIMIZED FOR TESTING: ~$0.13/hour (13p/hour)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found. Please install AWS CLI first.${NC}"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform not found. Please install Terraform first.${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites found${NC}"

# Check AWS credentials
echo "🔐 Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured. Run 'aws configure' first.${NC}"
    exit 1
fi

AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
if [ "$AWS_ACCOUNT" != "475641479654" ]; then
    echo -e "${YELLOW}⚠️  Warning: Expected AWS account 475641479654, but found $AWS_ACCOUNT${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}✅ AWS credentials configured for account: $AWS_ACCOUNT${NC}"

# Step 1: Generate secrets
echo ""
echo "🔑 Step 1: Generating secrets..."
if [ ! -f scripts/generate-secrets.sh ]; then
    echo -e "${RED}❌ scripts/generate-secrets.sh not found. Please ensure all files are in place.${NC}"
    exit 1
fi

chmod +x scripts/generate-secrets.sh
./scripts/generate-secrets.sh

# Step 2: Create ECR repository
echo ""
echo "📦 Step 2: Creating ECR repository..."
aws ecr describe-repositories --repository-names outline-app --region eu-west-2 &> /dev/null || {
    echo "Creating ECR repository..."
    aws ecr create-repository --repository-name outline-app --region eu-west-2
}
echo -e "${GREEN}✅ ECR repository ready${NC}"

# Step 3: Build and push Docker image
echo ""
echo "🐳 Step 3: Building and pushing Docker image..."

# Login to ECR
echo "Logging into ECR..."
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 475641479654.dkr.ecr.eu-west-2.amazonaws.com

# Build image
echo "Building Docker image..."
docker build -t outline-app .

# Tag and push
echo "Tagging and pushing image..."
docker tag outline-app:latest 475641479654.dkr.ecr.eu-west-2.amazonaws.com/outline-app:latest
docker push 475641479654.dkr.ecr.eu-west-2.amazonaws.com/outline-app:latest

echo -e "${GREEN}✅ Docker image pushed successfully${NC}"

# Step 4: Deploy infrastructure
echo ""
echo "🏗️ Step 4: Deploying infrastructure with Terraform..."

cd terraform

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Plan deployment
echo "Planning deployment..."
terraform plan -out=tfplan

# Apply deployment
echo "Applying deployment..."
terraform apply tfplan

echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}"

# Step 5: Get outputs
echo ""
echo "📋 Step 5: Getting deployment information..."

ALB_DNS=$(terraform output -raw alb_dns_name)
APP_URL=$(terraform output -raw application_url)

echo ""
echo -e "${GREEN}🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉${NC}"
echo ""
echo "📊 Deployment Summary:"
echo "===================="
echo "🔗 Application URL: $APP_URL"
echo "🌐 ALB DNS Name: $ALB_DNS"
echo "📧 Contact Email: islamadam436@gmail.com"
echo "👤 GitHub: aislam00"
echo "🌍 AWS Region: eu-west-2"
echo ""
echo -e "${YELLOW}📝 NEXT STEPS:${NC}"
echo "1. 🌐 Update your GoDaddy DNS:"
echo "   - Record Type: CNAME"
echo "   - Name: tm"
echo "   - Value: $ALB_DNS"
echo "   - TTL: 600"
echo ""
echo "2. ⏰ Wait 5-10 minutes for DNS propagation"
echo ""
echo "3. 🔍 Visit your application: $APP_URL"
echo ""
echo "4. 🔐 Set up Google OAuth (optional but recommended):"
echo "   - Go to Google Cloud Console"
echo "   - Create OAuth 2.0 credentials"
echo "   - Add redirect URI: $APP_URL/auth/google.callback"
echo "   - Update .env file with GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET"
echo ""
echo "5. 📸 Take screenshots for your README"
echo ""
echo "6. 🚀 Push to GitHub to activate CI/CD pipeline"
echo ""
echo -e "${GREEN}Happy documenting with Outline! 📝${NC}"