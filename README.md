# Refonte Cloud Engineer Project

This project provisions a robust, secure, and production-ready AWS infrastructure using **modular Terraform code**. The architecture supports scalability, observability, cost control, and secure CI/CD with Jenkins.


## Project Structure

```
root/
├── main.tf                # Entry point to all modules
├── provider.tf            # AWS provider configuration
├── variables.tf           # Input variables
├── outputs.tf             # Outputs from the root module
├── terraform.tfstate*     # Terraform state files             
 └── modules/               # Modular Terraform code
    ├── bastion/           # Bastion host config
    ├── cloudtrail/        # CloudTrail logging
    ├── cloudwatch/        # Dashboards, alarms, metrics
    ├── cost_optimization/ # Lambda for unused resources
    ├── iam_roles/         # IAM roles for all services
    ├── jenkins/           # IAM + EC2 Jenkins setup
    ├── kms/               # KMS encryption setup
    ├── lambda_cleanup/    # Python Lambda to clean up EIPs, volumes
    ├── load-balancer/     # Load Balancer config
    ├── nginx_frontend/    # Auto-scaled NGINX frontend
    ├── rds-mysql/         # Multi-AZ RDS MySQL
    ├── s3_logs/           # S3 logging bucket
    ├── secrets_manager/   # DB secrets store
    ├── vpc_peering/       # VPC peering between services
    ├── vpn/               # VPN gateway setup
    └── waf/               # Web Application Firewall
```

## Key Features


| Module Name        | Description |
|--------------------|-------------|
| **bastion**        | Provision a bastion host with a secure SSH setup using user data. 
| **cloudtrail**     | Enables AWS CloudTrail for governance, compliance, and auditing. 
| **cloudwatch**     | Sets up monitoring, alarms, logs, and dashboards for key services. 
| **cost_optimization** | Defines policies and recommendations for cost-effective resource usage. 
| **iam_roles**      | Creates IAM roles and policies used by Lambda, EC2, Jenkins, and others. 
| **jenkins**        | Installs Jenkins on an EC2 instance for CI/CD orchestration. |
| **kms**            | Configures AWS Key Management Service (KMS) keys for encryption. |
| **lambda_cleanup** | Deploys a Lambda function to clean up unused resources automatically. |
| **nginx_frontend** | Launches an EC2 instance running Nginx to serve the frontend app. |
| **rds-mysql**      | Deploys an RDS MySQL database in a multi-AZ setup with enhanced security. |
| **s3_logs**        | Creates S3 buckets to store logs (e.g., from CloudTrail, ALB, etc.). |
| **secrets_manager**| Manages sensitive credentials and secrets securely using AWS Secrets Manager. |
| **vpc_peering**    | Establishes VPC peering between multiple VPCs for network access. |
| **vpn**            | Configures a VPN connection for secure access to the private network. |
| **waf**            | Sets up AWS Web Application Firewall (WAF) for web app protection. | 


## 🚀 Getting Started

### ✅ Prerequisites

- Terraform v1.4+
- AWS CLI configured (`aws configure`)
- Sufficient IAM permissions for provisioning infrastructure

### 🔧 Commands

Initialize Terraform:

```bash
terraform init 

Check configuration:
terraform validate

Preview changes: 
terraform plan -out=tfplan

Apply infrastructure:
terraform apply tfplan

 👩🏾‍💻 Author
Ernestine D. Motouom
📅 Last updated: July 2025
