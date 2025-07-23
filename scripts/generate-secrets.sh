#!/bin/bash
# scripts/generate-secrets.sh
# Script to generate required secrets for Outline

set -e

echo "🔑 Generating secrets for Outline deployment..."

# Generate 32-byte hex secrets
SECRET_KEY=$(openssl rand -hex 32)
UTILS_SECRET=$(openssl rand -hex 32)

echo ""
echo "📝 Generated secrets (save these in your .env file):"
echo "SECRET_KEY=$SECRET_KEY"
echo "UTILS_SECRET=$UTILS_SECRET"
echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📄 Creating .env file..."
    cat > .env << EOF
# Outline Environment Configuration
# Generated on $(date)

# ------ REQUIRED SECRETS ------
SECRET_KEY=$SECRET_KEY
UTILS_SECRET=$UTILS_SECRET

# ------ REQUIRED CONFIGURATION ------
NODE_ENV=production
URL=https://tm.integratepro.online
PORT=3000

# Database (will be populated by Terraform)
DATABASE_URL=postgresql://outline:PLACEHOLDER@outline-db.cluster-xyz.eu-west-2.rds.amazonaws.com:5432/outline
DATABASE_URL_TEST=postgresql://outline:PLACEHOLDER@outline-db.cluster-xyz.eu-west-2.rds.amazonaws.com:5432/outline_test

# Redis (will be populated by Terraform)
REDIS_URL=redis://outline-redis.cache.amazonaws.com:6379/0

# File Storage
FILE_STORAGE=local
FILE_STORAGE_LOCAL_ROOT_DIR=/var/lib/outline/data

# ------ OPTIONAL CONFIGURATION ------
DEFAULT_LANGUAGE=en_US
FORCE_HTTPS=true
ENFORCE_HTTPS=true

# Rate Limiting
RATE_LIMITER_ENABLED=true
RATE_LIMITER_REQUESTS=1000
RATE_LIMITER_DURATION_WINDOW=60

# Collaboration
COLLABORATION_URL=https://tm.integratepro.online

# ------ AUTHENTICATION (Configure after deployment) ------
# Google OAuth - Get these from Google Cloud Console
# GOOGLE_CLIENT_ID=your-google-client-id
# GOOGLE_CLIENT_SECRET=your-google-client-secret

# ------ EMAIL (Optional) ------
# SMTP_HOST=smtp.gmail.com
# SMTP_PORT=587
# SMTP_USERNAME=your-email@gmail.com
# SMTP_PASSWORD=your-app-password
# SMTP_FROM_EMAIL=outline@integratepro.online
# SMTP_REPLY_EMAIL=noreply@integratepro.online

# ------ LOGGING ------
LOG_LEVEL=info
DEBUG=
EOF
    echo "✅ Created .env file with generated secrets"
else
    echo "⚠️  .env file already exists. Please manually update with the generated secrets above."
fi

echo ""
echo "🚀 Next steps:"
echo "1. Review and update the .env file with your specific configuration"
echo "2. Set up Google OAuth credentials (optional but recommended)"
echo "3. Configure SMTP settings for email notifications (optional)"
echo "4. Run the deployment with: cd terraform && terraform apply"
echo ""