#!/bin/bash

# Diagnose your Terraform repository structure
# Run this script from your repository root directory

echo "🔍 DIAGNOSING TERRAFORM REPOSITORY STRUCTURE"
echo "=============================================="
echo ""

# Check if we're in the right place
if [ ! -d ".git" ]; then
    echo "⚠️  Warning: No .git directory found. Make sure you're in your repository root."
fi

echo "📂 CURRENT DIRECTORY:"
pwd
echo ""

echo "📁 TERRAFORM DIRECTORY STRUCTURE:"
if [ -d "terraform" ]; then
    echo "✅ terraform/ directory exists"
    cd terraform
    
    echo ""
    echo "📄 ROOT TERRAFORM FILES:"
    ls -la *.tf 2>/dev/null || echo "❌ No .tf files in terraform root"
    
    echo ""
    echo "📂 MODULES DIRECTORY:"
    if [ -d "modules" ]; then
        echo "✅ modules/ directory exists"
        echo ""
        echo "🎯 MODULE STRUCTURE:"
        for module_dir in modules/*/; do
            if [ -d "$module_dir" ]; then
                module_name=$(basename "$module_dir")
                echo "  📁 $module_name/"
                for tf_file in "$module_dir"*.tf; do
                    if [ -f "$tf_file" ]; then
                        filename=$(basename "$tf_file")
                        echo "    ✅ $filename"
                    fi
                done
                # Check for missing standard files
                for required_file in main.tf variables.tf outputs.tf; do
                    if [ ! -f "$module_dir$required_file" ]; then
                        echo "    ❌ MISSING: $required_file"
                    fi
                done
                echo ""
            fi
        done
    else
        echo "❌ modules/ directory does not exist"
    fi
    
    cd ..
else
    echo "❌ terraform/ directory does not exist"
    echo ""
    echo "🔍 LOOKING FOR TERRAFORM FILES IN CURRENT DIRECTORY:"
    find . -name "*.tf" -type f | head -10
fi

echo ""
echo "🚨 TERRAFORM VALIDATION:"
if [ -d "terraform" ]; then
    cd terraform
    if command -v terraform &> /dev/null; then
        echo "Running terraform validate..."
        terraform validate 2>&1 | head -20
    else
        echo "❌ Terraform not installed or not in PATH"
    fi
    cd ..
else
    echo "❌ Cannot validate - no terraform directory"
fi

echo ""
echo "📋 SUMMARY:"
echo "==========="

# Count files
terraform_files=$(find . -name "*.tf" -type f 2>/dev/null | wc -l)
echo "Total .tf files found: $terraform_files"

# Check critical paths
critical_files=(
    "terraform/main.tf"
    "terraform/variables.tf" 
    "terraform/outputs.tf"
    "terraform/modules/alb/main.tf"
    "terraform/modules/alb/variables.tf"
    "terraform/modules/elasticache/main.tf"
    "terraform/modules/elasticache/variables.tf"
)

echo ""
echo "🎯 CRITICAL FILES STATUS:"
for file in "${critical_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ MISSING: $file"
    fi
done

echo ""
echo "📤 SHARE THIS OUTPUT:"
echo "Copy everything above and paste it in your response so I can see exactly what files you have and what's missing."
