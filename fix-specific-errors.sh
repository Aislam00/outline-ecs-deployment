#!/bin/bash

# Fix Terraform state when AWS resources are out of sync
# Run this from your terraform directory

set -e

echo "🔧 FIXING TERRAFORM STATE SYNC ISSUES"
echo "====================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if we're in the terraform directory
if [ ! -f "main.tf" ]; then
    print_error "Not in terraform directory. Please run from terraform/ folder."
    exit 1
fi

print_status "Checking Terraform state..."

# Option 1: Remove orphaned resources from state (Recommended)
fix_orphaned_resources() {
    print_status "Removing orphaned ALB resources from Terraform state..."
    
    # List of resources that are causing issues
    orphaned_resources=(
        "module.alb.aws_lb.main"
        "module.alb.aws_lb_target_group.main"
        "module.alb.aws_lb_listener.http"
        "module.alb.aws_lb_listener.https"
    )
    
    for resource in "${orphaned_resources[@]}"; do
        if terraform state show "$resource" &>/dev/null; then
            print_warning "Removing $resource from state..."
            terraform state rm "$resource" || print_warning "Resource $resource not found in state"
        else
            print_status "Resource $resource not in state"
        fi
    done
    
    print_success "Orphaned resources removed from state"
}

# Option 2: Import existing resources (if they exist)
import_existing_resources() {
    print_status "Attempting to import existing AWS resources..."
    
    # Check if ALB exists in AWS
    alb_arn=$(aws elbv2 describe-load-balancers --names "outline-alb" --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || echo "None")
    
    if [ "$alb_arn" != "None" ] && [ "$alb_arn" != "null" ]; then
        print_status "Found existing ALB: $alb_arn"
        terraform import module.alb.aws_lb.main "$alb_arn"
    else
        print_warning "No existing ALB found to import"
    fi
}

# Option 3: Full state refresh
refresh_state() {
    print_status "Refreshing Terraform state..."
    terraform refresh
    print_success "State refreshed"
}

# Main menu
echo "Choose how to fix the state sync issue:"
echo ""
echo "1) Remove orphaned resources from state (Recommended)"
echo "2) Import existing AWS resources (if they exist)"
echo "3) Full state refresh"
echo "4) Nuclear option: Delete state and start fresh"
echo "5) Exit"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        fix_orphaned_resources
        print_status "Validating fix..."
        if terraform plan -detailed-exitcode; then
            print_success "State fixed! Resources removed successfully."
        else
            print_status "Plan shows changes needed. This is normal after removing resources."
        fi
        ;;
    2)
        import_existing_resources
        ;;
    3)
        refresh_state
        ;;
    4)
        print_warning "This will delete your Terraform state file!"
        print_warning "You'll need to recreate all resources."
        read -p "Are you ABSOLUTELY sure? Type 'yes' to continue: " confirm
        if [ "$confirm" = "yes" ]; then
            rm -f terraform.tfstate terraform.tfstate.backup
            rm -rf .terraform/
            print_warning "State deleted. Run 'terraform init' and 'terraform plan' to start fresh."
        else
            print_status "Operation cancelled."
        fi
        ;;
    5)
        print_status "Exiting..."
        exit 0
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_status "Next steps:"
echo "1. Run 'terraform plan' to see what changes are needed"
echo "2. Run 'terraform apply' to create missing resources"
echo "3. Or run 'terraform destroy' to clean up everything"#!/bin/bash

# Fix the specific Terraform errors you encountered
# Run this from your repository root

echo "🔧 FIXING SPECIFIC TERRAFORM ERRORS"
echo "===================================="

cd terraform

# Fix 1: ALB module variable references
echo "📝 Fixing ALB module variables..."
if [ -f "modules/alb/main.tf" ]; then
    # Create backup
    cp modules/alb/main.tf modules/alb/main.tf.backup
    
    # Fix the variable references based on your error messages
    sed -i '' 's/var\.name\b/var.name_prefix/g' modules/alb/main.tf
    sed -i '' 's/var\.security_group_ids/[var.security_group_id]/g' modules/alb/main.tf
    sed -i '' 's/var\.subnets/var.public_subnet_ids/g' modules/alb/main.tf
    sed -i '' 's/var\.enable_deletion_protection/false/g' modules/alb/main.tf
    sed -i '' 's/var\.target_port/3000/g' modules/alb/main.tf
    sed -i '' 's/var\.target_protocol/"HTTP"/g' modules/alb/main.tf
    sed -i '' 's/var\.health_check_healthy_threshold/2/g' modules/alb/main.tf
    sed -i '' 's/var\.health_check_interval/30/g' modules/alb/main.tf
    sed -i '' 's/var\.health_check_matcher/"200"/g' modules/alb/main.tf
    sed -i '' 's/var\.health_check_path/"\/"/g' modules/alb/main.tf
    sed -i '' 's/var\.health_check_timeout/5/g' modules/alb/main.tf
    sed -i '' 's/var\.health_check_unhealthy_threshold/2/g' modules/alb/main.tf
    
    echo "✅ ALB module variables fixed"
else
    echo "❌ ALB main.tf not found"
fi

# Fix 2: ElastiCache invalid argument
echo "📝 Fixing ElastiCache module..."
if [ -f "modules/elasticache/main.tf" ]; then
    # Create backup
    cp modules/elasticache/main.tf modules/elasticache/main.tf.backup
    
    # Remove the invalid auth_token_enabled line
    sed -i '' '/auth_token_enabled.*=.*false/d' modules/elasticache/main.tf
    
    echo "✅ ElastiCache invalid argument removed"
else
    echo "❌ ElastiCache main.tf not found"
fi

echo ""
echo "🔍 VALIDATING FIXES..."
if terraform validate; then
    echo "✅ All fixes successful! Configuration is valid."
    echo ""
    echo "🧹 Cleaning up backup files..."
    rm -f modules/alb/main.tf.backup
    rm -f modules/elasticache/main.tf.backup
    echo "✅ Backup files cleaned up"
else
    echo "❌ Still have validation errors. Restoring backups..."
    if [ -f "modules/alb/main.tf.backup" ]; then
        mv modules/alb/main.tf.backup modules/alb/main.tf
    fi
    if [ -f "modules/elasticache/main.tf.backup" ]; then
        mv modules/elasticache/main.tf.backup modules/elasticache/main.tf
    fi
    echo "🔄 Backups restored. Please check the errors above."
fi

echo ""
echo "🚀 NEXT STEPS:"
echo "1. Run 'terraform plan' to see what will be created"
echo "2. Run 'terraform apply' to deploy your infrastructure"
echo "3. Or run 'terraform destroy' if you want to clean up resources"
