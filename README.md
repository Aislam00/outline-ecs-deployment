# 🚀 Outline Knowledge Base - AWS ECS Deployment

[![Terraform](https://img.shields.io/badge/Terraform-1.6+-blue.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20RDS%20%7C%20ALB-orange.svg)](https://aws.amazon.com/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-green.svg)](https://github.com/features/actions)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A production-ready, cost-optimized deployment of [Outline](https://www.getoutline.com/) knowledge base on AWS using Infrastructure as Code (IaC) with Terraform, containerized with Docker, and automated with CI/CD pipelines.

## 📋 Table of Contents

- [Architecture](#-architecture)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Cost Analysis](#-cost-analysis)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Monitoring](#-monitoring)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CloudFlare    │    │     Route 53     │    │     GoDaddy     │
│      CDN        │    │       DNS        │    │     Domain      │
└─────────┬───────┘    └──────────┬───────┘    └─────────┬───────┘
          │                       │                      │
          └───────────────────────┼──────────────────────┘
                                  │
                          ┌───────▼───────┐
                          │ Application   │
                          │ Load Balancer │
                          │   (HTTPS)     │
                          └───────┬───────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
            ┌───────▼───────┐ ┌───▼───┐ ┌───────▼───────┐
            │  ECS Fargate  │ │  ECS  │ │  ECS Fargate  │
            │   (AZ-a)      │ │Service│ │   (AZ-b)      │
            └───────┬───────┘ └───────┘ └───────┬───────┘
                    │                           │
                    └─────────────┬─────────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │         VPC               │
                    │  ┌─────────────────────┐  │
                    │  │  Private Subnets   │  │
                    │  │                    │  │
                    │  │ ┌─────┐  ┌───────┐ │  │
                    │  │ │ RDS │  │ Redis │ │  │
                    │  │ │ DB  │  │ Cache │ │  │
                    │  │ └─────┘  └───────┘ │  │
                    │  └─────────────────────┘  │
                    └───────────────────────────┘
```

### Infrastructure Components

- **VPC**: Custom VPC with public/private subnets across 2 AZs
- **Application Load Balancer**: HTTPS termination with SSL certificate
- **ECS Fargate**: Serverless container orchestration
- **RDS PostgreSQL**: Managed database with Multi-AZ support
- **ElastiCache Redis**: In-memory caching layer
- **ACM**: SSL certificate management
- **Route 53**: DNS management (optional)

## ✨ Features

### 🏢 Production-Ready
- **High Availability**: Multi-AZ deployment across 2 availability zones
- **Auto Scaling**: ECS service auto-scaling based on CPU/memory
- **SSL/TLS**: Automatic HTTPS with Let's Encrypt-style certificates
- **Health Checks**: Application and infrastructure health monitoring

### 💰 Cost-Optimized
- **Single NAT Gateway**: Saves ~$45/month vs dual NAT setup
- **t3.micro Instances**: Free tier eligible for DB and cache
- **Fargate Spot**: Cost savings on compute (optional)
- **Resource Tagging**: Complete cost allocation and tracking

### 🔒 Security-First
- **Private Subnets**: Database and cache in isolated networks
- **Security Groups**: Least-privilege network access
- **Secrets Management**: AWS Systems Manager Parameter Store
- **Infrastructure Scanning**: Automated security validation

### 🚀 DevOps Excellence
- **Infrastructure as Code**: 100% Terraform with modular design
- **CI/CD Pipeline**: GitHub Actions for automated deployments
- **Container-Ready**: Multi-stage Docker builds
- **Monitoring**: CloudWatch integration with custom dashboards

## 📊 Cost Analysis

### Monthly AWS Costs (EU-West-2)
| Service | Instance Type | Estimated Cost |
|---------|---------------|----------------|
| ALB | Application Load Balancer | $20-25 |
| ECS | Fargate (512MB, 0.25vCPU) | $8-12 |
| RDS | db.t3.micro PostgreSQL | $12-15 |
| ElastiCache | cache.t3.micro Redis | $10-12 |
| NAT Gateway | Single NAT (optimized) | $45 |
| VPC | Data transfer & networking | $5-10 |
| **Total** | | **~$100-120/month** |

### Cost Optimizations Applied
- ✅ **Single NAT Gateway**: Reduced from 2 to 1 (saves $45/month)
- ✅ **Free Tier Resources**: t3.micro for RDS and Redis
- ✅ **Minimal ECS Resources**: Right-sized containers
- ✅ **7-day Log Retention**: Reduced CloudWatch costs

## 🛠️ Prerequisites

- **AWS Account** with appropriate IAM permissions
- **Domain Name** (e.g., from GoDaddy, Route53)
- **Terraform** >= 1.6.0
- **Docker** (for container builds)
- **AWS CLI** configured with credentials

### Required IAM Permissions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "ecs:*",
        "rds:*",
        "elasticache:*",
        "elasticloadbalancing:*",
        "acm:*",
        "route53:*",
        "ssm:*",
        "logs:*",
        "iam:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/outline-ecs-deployment.git
cd outline-ecs-deployment
```

### 2. Configure Variables
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
# General Configuration
aws_region   = "eu-west-2"
project_name = "outline"
environment  = "prod"
domain_name  = "yourdomain.com"

# Secrets (generate with: openssl rand -hex 32)
secret_key   = "your-32-char-secret-key"
utils_secret = "your-32-char-utils-secret"
```

### 3. Deploy Infrastructure
```bash
cd terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Deploy (takes ~15 minutes)
terraform apply
```

### 4. Configure DNS
After deployment, add these DNS records to your domain:

**Certificate Validation:**
```
Type: CNAME
Name: [validation-name-from-acm]
Value: [validation-value-from-acm]
```

**Website:**
```
Type: CNAME
Name: www
Value: [alb-dns-name-from-terraform-output]
```

### 5. Access Application
Visit `https://yourdomain.com` and complete the Outline setup wizard!

## 🔄 CI/CD Pipeline

The project includes a complete GitHub Actions pipeline:

### Pipeline Stages
1. **Validate**: Terraform formatting, validation, and security scanning
2. **Plan**: Generate and review deployment plan
3. **Apply**: Deploy to production (main branch only)
4. **Destroy**: Manual infrastructure teardown (workflow_dispatch)

### Setup GitHub Secrets
```bash
# Required secrets in GitHub repository settings:
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
OUTLINE_SECRET_KEY=your-32-char-secret
OUTLINE_UTILS_SECRET=your-32-char-secret
```

### Workflow Triggers
- **Push to main**: Full deployment
- **Pull Request**: Validation and planning only
- **Manual**: Destroy infrastructure (cost management)

## 📈 Monitoring

### CloudWatch Dashboards
- **Application Metrics**: Response time, error rates
- **Infrastructure Metrics**: CPU, memory, network
- **Cost Metrics**: Daily spend tracking

### Health Checks
- **ALB Health Check**: HTTP 200 on `/`
- **ECS Health Check**: Container health monitoring
- **RDS Monitoring**: Database performance metrics

### Alerts
- **High CPU/Memory**: ECS task scaling triggers
- **Database Connection**: RDS connection monitoring
- **Cost Alerts**: Monthly spend notifications

## 🔒 Security

### Security Best Practices Implemented
- ✅ **Network Isolation**: Private subnets for databases
- ✅ **Least Privilege**: Minimal security group rules
- ✅ **Secrets Management**: No hardcoded secrets
- ✅ **SSL Everywhere**: HTTPS-only communication
- ✅ **Infrastructure Scanning**: Automated security validation

### Security Scanning
```bash
# Run security scan locally
tfsec terraform/

# Run compliance check
checkov -d terraform/
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Certificate Validation Pending
```bash
# Check certificate status
aws acm describe-certificate --certificate-arn [cert-arn] --query 'Certificate.Status'

# Verify DNS records
nslookup [validation-record-name]
```

#### 2. ECS Tasks Failing
```bash
# Check ECS service status
aws ecs describe-services --cluster [cluster-name] --services [service-name]

# View application logs
aws logs tail /ecs/outline-prod --follow
```

#### 3. Database Connection Issues
```bash
# Test database connectivity
aws rds describe-db-instances --db-instance-identifier [db-name]

# Check security groups
aws ec2 describe-security-groups --group-ids [sg-id]
```

### Cost Management
```bash
# Destroy infrastructure to save costs
terraform destroy -auto-approve

# Rebuild when needed
terraform apply
```

## 📚 Project Structure

```
outline-ecs-deployment/
├── .github/
│   └── workflows/
│       └── terraform-cicd.yml      # CI/CD pipeline
├── terraform/
│   ├── modules/
│   │   ├── vpc/                    # VPC and networking
│   │   ├── security-groups/        # Security group rules
│   │   ├── alb/                    # Application Load Balancer
│   │   ├── acm/                    # SSL certificate
│   │   ├── rds/                    # PostgreSQL database
│   │   ├── elasticache/            # Redis cache
│   │   └── ecs/                    # Container orchestration
│   ├── main.tf                     # Main infrastructure
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Output values
│   └── terraform.tfvars.example    # Configuration template
├── docker/
│   ├── Dockerfile                  # Multi-stage container build
│   ├── docker-compose.yml          # Local development
│   └── .dockerignore              # Build optimization
├── scripts/
│   ├── deploy.sh                   # Deployment automation
│   └── build-and-push.sh          # Container registry
├── docs/
│   ├── ARCHITECTURE.md             # Detailed architecture
│   ├── COST_OPTIMIZATION.md       # Cost reduction strategies
│   └── TROUBLESHOOTING.md          # Detailed troubleshooting
└── README.md                       # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Workflow
```bash
# Local testing
terraform fmt -recursive
terraform validate
terraform plan

# Security scanning
tfsec terraform/
checkov -d terraform/
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Outline](https://www.getoutline.com/) - The amazing knowledge base application
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws) - Infrastructure automation
- [AWS ECS](https://aws.amazon.com/ecs/) - Container orchestration platform

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/outline-ecs-deployment/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/outline-ecs-deployment/discussions)
- **Email**: your.email@example.com

---

**⭐ If this project helped you, please give it a star!**
