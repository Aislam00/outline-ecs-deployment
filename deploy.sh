#!/bin/bash

# Outline ECS Deployment Script
# This script helps deploy the Outline application infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform >= 1.0"
        exit 1
    fi
    
    # Check terraform version
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_status "Terraform version: $TERRAFORM_VERSION"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure'"
        exit 1
    fi
    
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    AWS_REGION=$(aws configure get region)
    print_status "AWS Account: $AWS_ACCOUNT"
    print_status "AWS Region: $AWS_REGION"
    
    print_success "Prerequisites check passed!"
}

# Function to setup terraform.tfvars
setup_tfvars() {
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Copying from example..."
        cp terraform.tfvars.example terraform.tfvars
        
        print_warning "Please edit terraform.tfvars with your configuration:"
        echo "  - domain_name: Your domain (e.g., example.com)"
        echo "  - secret_key: Long random string (32+ characters)"
        echo "  - utils_secret: Another long random string (32+ characters)"
        echo ""
        read -p "Press Enter after you've edited terraform.tfvars..."
    fi
    
    # Validate required variables
    if ! grep -q "domain_name.*=" terraform.tfvars || grep -q "your-domain.com" terraform.tfvars; then
        print_error "Please set a valid domain_name in terraform.tfvars"
        exit 1
    fi
    
    if ! grep -q "secret_key.*=" terraform.tfvars || grep -q "your-secret-key-here" terraform.tfvars; then
        print_error "Please set a valid secret_key in terraform.tfvars"
        exit 1
    fi
    
    print_success "terraform.tfvars configuration validated!"
}

# Function to generate random secrets
generate_secrets() {
    print_status "Generating random secrets..."
    
    SECRET_KEY=$(openssl rand -hex 32)
    UTILS_SECRET=$(openssl rand -hex 32)
    
    echo "Generated secrets (save these securely):"
    echo "SECRET_KEY: $SECRET_KEY"
    echo "UTILS_SECRET: $UTILS_SECRET"
    echo ""
    
    # Update terraform.tfvars if it has placeholder values
    if grep -q "your-secret-key-here" terraform.tfvars; then
        sed -i.bak "s/your-secret-key-here-make-it-long-and-random/$SECRET_KEY/" terraform.tfvars
        print_status "Updated secret_key in terraform.tfvars"
    fi
    
    if grep -q "your-utils-secret-here" terraform.tfvars; then
        sed -i.bak "s/your-utils-secret-here-make-it-long-and-random/$UTILS_SECRET/" terraform.tfvars
        print_status "Updated utils_secret in terraform.tfvars"
    fi
}

# Function to estimate costs
estimate_costs() {
    print_status "Estimated monthly AWS costs (excluding free tier):"
    echo "  - RDS db.t3.micro: ~$12-15"
    echo "  - ElastiCache cache.t3.micro: ~$10-12"
    echo "  - ECS Fargate (1 task, 0.5 vCPU, 1GB): ~$5-8"
    echo "  - ALB: ~$20-25"
    echo "  - NAT Gateway: ~$45"
    echo "  - Data transfer and other services: ~$5-10"
    echo "  ----------------------------------------"
    echo "  Total estimated: ~$95-115 per month"
    echo ""
    print_warning "For cost optimization, consider:"
    echo "  - Using single NAT Gateway (reduces cost by ~$45)"
    echo "  - Using NAT instances instead of NAT Gateway"
    echo "  - Stopping services when not in use"
    echo ""
}

# Function to deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying infrastructure..."
    
    # Initialize Terraform
    print_status "Running terraform init..."
    terraform init
    
    # Plan deployment
    print_status "Running terraform plan..."
    terraform plan -out=tfplan
    
    # Confirm deployment
    echo ""
    print_warning "Review the plan above. This will create AWS resources that may incur costs."
    read -p "Do you want to proceed with the deployment? (yes/no): " CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        print_status "Deployment cancelled."
        exit 0
    fi
    
    # Apply deployment
    print_status "Running terraform apply..."
    terraform apply tfplan
    
    print_success "Infrastructure deployed successfully!"
}

# Function to display post-deployment instructions
post_deployment_instructions() {
    print_success "Deployment completed!"
    echo ""
    print_status "Next steps:"
    echo "1. SSL Certificate Validation:"
    echo "   - Go to AWS Certificate Manager console"
    echo "   - Find your certificate and copy the DNS validation records"
    echo "   - Add the CNAME records to your domain's DNS"
    echo "   - Wait for validation (5-10 minutes)"
    echo ""
    echo "2. Domain DNS Setup:"
    echo "   - Point your domain to the ALB DNS name shown in the output above"
    echo "   - Use CNAME record or A record (if using Route53 alias)"
    echo ""
    echo "3. Wait for services to start:"
    echo "   - ECS tasks may take 5-10 minutes to become healthy"
    echo "   - Check ECS console for task status"
    echo ""
    echo "4. Access your application:"
    DOMAIN=$(grep "domain_name" terraform.tfvars | cut -d'"' -f2)
    echo "   - Once DNS propagates: https://$DOMAIN"
    echo ""
    print_status "Monitoring:"
    echo "   - CloudWatch Logs: /ecs/$(grep "project_name" terraform.tfvars | cut -d'"' -f2 || echo "outline")-$(grep "environment" terraform.tfvars | cut -d'"' -f2 || echo "prod")"
    echo "   - ECS Console: Check service and task status"
    echo ""
}

# Function to show help
show_help() {
    echo "Outline ECS Deployment Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy      - Full deployment (default)"
    echo "  check       - Check prerequisites only"
    echo "  secrets     - Generate random secrets"
    echo "  cost        - Show cost estimates"
    echo "  destroy     - Destroy all resources"
    echo "  help        - Show this help"
    echo ""
}

# Function to destroy infrastructure
destroy_infrastructure() {
    print_warning "This will destroy ALL resources and data!"
    print_warning "Make sure you have backups if needed."
    echo ""
    read -p "Are you sure you want to destroy all resources? (type 'yes' to confirm): " CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        print_status "Destruction cancelled."
        exit 0
    fi
    
    print_status "Destroying infrastructure..."
    terraform destroy
    print_success "Infrastructure destroyed!"
}

# Main script logic
main() {
    cd "$(dirname "$0")/terraform" 2>/dev/null || {
        print_error "Please run this script from the root directory of the project"
        exit 1
    }
    
    case "${1:-deploy}" in
        "check")
            check_prerequisites
            ;;
        "secrets")
            generate_secrets
            ;;
        "cost")
            estimate_costs
            ;;
        "destroy")
            check_prerequisites
            destroy_infrastructure
            ;;
        "deploy")
            check_prerequisites
            setup_tfvars
            estimate_costs
            deploy_infrastructure
            post_deployment_instructions
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"