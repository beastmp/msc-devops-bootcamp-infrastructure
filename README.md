# DevOps Bootcamp

## Overview

This repository contains the infrastructure code, resources, and documentation for the CloudMart project, developed as part of the DevOps Bootcamp. The project demonstrates modern DevOps practices, infrastructure as code, containerization, and AI integration in a multi-cloud environment.

## Project Structure

The project is organized into four main repositories:

- **msc-devops-bootcamp-infrastructure** (this repo): Infrastructure as code with Terraform and documentation
- **msc-devops-bootcamp-frontend**: React-based UI for the CloudMart e-commerce application 
- **msc-devops-bootcamp-backend**: Node.js API with AWS service integrations
- **msc-devops-bootcamp-kubernetes**: Kubernetes configuration for deployment

### This Repository Structure

```
msc-devops-bootcamp/
├── docs/                   # Daily tutorials and guides
│   ├── Day01.md            # Terraform basics with AWS
│   ├── Day02.md            # Docker and Kubernetes setup
│   ├── Day03.md            # CI/CD with AWS CodePipeline
│   ├── Day04.md            # AI integration with Bedrock and OpenAI
│   └── Day05.md            # Multi-cloud setup with Google Cloud
├── modules/                # Terraform modules
│   ├── compute/            # EC2 and EKS resources
│   │   ├── ec2/            # EC2 instance configuration
│   │   └── eks/            # EKS cluster and user configuration
│   ├── container/          # Container registry resources
│   │   └── ecr/            # ECR repository configuration
│   ├── pipeline/           # CI/CD pipeline resources
│   │   └── codepipeline/   # AWS CodePipeline configuration
│   ├── security/           # Security-related resources
│   │   ├── iam/            # IAM roles and policies
│   │   └── kms/            # Encryption key management
│   └── storage/            # Storage resources
│       ├── dynamodb/       # DynamoDB tables
│       └── s3/             # S3 buckets
└── README.md               # Project documentation
```

## Infrastructure Components

This repository contains Terraform modules for:

1. **Amazon ECR Repositories**: Docker image registry for CloudMart frontend and backend
2. **Amazon EKS Cluster**: Kubernetes cluster for container orchestration
3. **EC2 Instances**: Compute resources for development and CI/CD processes
4. **IAM Roles and Policies**: Identity and access management for AWS resources
5. **DynamoDB Tables**: NoSQL database tables for product and order data

## Daily Learning Path

The `docs` directory contains step-by-step tutorials for each day of the bootcamp:

1. **Day 1**: Introduction to Terraform and AWS, setting up foundational infrastructure
2. **Day 2**: Docker containerization and Kubernetes deployment on AWS EKS
3. **Day 3**: Implementing CI/CD with AWS CodePipeline and GitHub integration
4. **Day 4**: AI integration using AWS Bedrock and OpenAI
5. **Day 5**: Multi-cloud setup with Google Cloud BigQuery and Azure Text Analytics

## Prerequisites

- Git
- Docker and Docker Compose
- Kubernetes CLI (kubectl)
- AWS CLI
- Terraform (v1.0 or later)
- A code editor (VS Code recommended)
- Node.js (for frontend/backend development)
- AWS account with appropriate permissions
- Google Cloud and Azure accounts (for multi-cloud components)

## Getting Started

1. Clone all repositories:
   ```bash
   git clone https://github.com/beastmp/msc-devops-bootcamp-infrastructure.git
   git clone https://github.com/beastmp/msc-devops-bootcamp-frontend.git
   git clone https://github.com/beastmp/msc-devops-bootcamp-backend.git
   git clone https://github.com/beastmp/msc-devops-bootcamp-kubernetes.git
   ```

2. Open the workspace file to load all projects in VS Code:
   ```bash
   code docs/msc-devops-bootcamp.code-workspace
   ```

3. Follow the day-by-day instructions in the docs folder to progress through the bootcamp.

## Terraform Usage

Initialize Terraform in the project root:
```bash
terraform init
```

Create the required AWS resources:
```bash
terraform apply
```

## Development Workflow

1. Create a feature branch from `main`
2. Implement your changes using the Terraform modules
3. Test your changes locally
4. Submit a Pull Request
5. After code review and approval, merge to `main`
6. Apply changes to your cloud environment

## CloudMart E-commerce Application

The CloudMart application is a modern e-commerce platform with:

- Product catalog and shopping cart functionality
- Order management system
- AI-powered product recommendations using AWS Bedrock
- Customer support chat using OpenAI
- Multi-cloud analytics with Google BigQuery and Azure Text Analytics

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please contact [beastmpdevelopment@gmail.com](mailto:beastmpdevelopment@gmail.com)