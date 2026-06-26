# Day 26 — Terraform & Infrastructure as Code (AWS Focus)

Today I learned Infrastructure as Code — define AWS infrastructure
in code files, version control it, deploy it automatically.

No more clicking in AWS console. Write code → infrastructure is created.

---

## What Is Infrastructure as Code (IaC)

Traditional:
````
1. Log into AWS console
2. Click 47 times
3. Configure things
4. Hope you remember next time
````

IaC:
````
1. Write main.tf
2. terraform apply
3. Infrastructure is created exactly as specified
4. Commit to Git → infrastructure is versioned
````

---

## Why Terraform

````
Terraform = write infrastructure as code

You write:
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
}

Terraform does:
- Connects to AWS
- Creates EC2 instance
- Tracks what it created (state file)
- Can update or destroy it
````

---

## Terraform Workflow

````
1. Write code (main.tf)
        ↓
2. terraform init (setup)
        ↓
3. terraform plan (preview changes)
        ↓
4. terraform apply (make changes)
        ↓
5. Verify in AWS console
        ↓
6. terraform destroy (cleanup)
````

---

## Key Concepts

### Provider
Connects Terraform to AWS (or other cloud)

````hcl
provider "aws" {
  region = "us-east-1"
}
````

### Resource
An AWS thing you want to create

````hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
}
````

### Variables
Inputs to your configuration

````hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

resource "aws_instance" "web" {
  instance_type = var.instance_type
}
````

### Outputs
Results you want to see

````hcl
output "instance_ip" {
  value = aws_instance.web.public_ip
}
````

### State File
Terraform's memory of what it created

````
terraform.tfstate (tracks resources)
terraform.tfstate.backup (automatic backup)

NEVER commit to Git!
NEVER edit manually!
````

---

## AWS Resources via Terraform

### EC2 Instance

````hcl
resource "aws_instance" "web" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  
  tags = {
    Name = "web-server"
  }
}
````

### RDS Database

````hcl
resource "aws_db_instance" "postgres" {
  identifier            = "myapp-db"
  engine                = "postgres"
  instance_class        = "db.t2.micro"
  allocated_storage     = 20
  
  db_name  = "myappdb"
  username = "postgres"
  password = "MyPassword123!"
  
  skip_final_snapshot = true
}
````

### S3 Bucket

````hcl
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-bucket"
  
  tags = {
    Name = "app-bucket"
  }
}
````

### VPC

````hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  
  tags = {
    Name = "public-subnet"
  }
}
````

### Security Group

````hcl
resource "aws_security_group" "web" {
  name = "web-sg"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
````

---

## File Structure

````
terraform-project/
├── main.tf              (main resources)
├── variables.tf         (inputs)
├── outputs.tf           (outputs)
├── terraform.tfvars     (variable values — don't commit!)
├── .gitignore           (ignore tfstate, tfvars)
└── .terraform/          (Terraform directory — don't commit!)
````

---

## Terraform Commands

````bash
# Initialize
terraform init

# Plan changes (preview)
terraform plan
terraform plan -out=tfplan

# Apply changes
terraform apply
terraform apply tfplan

# Destroy resources
terraform destroy

# View current state
terraform show
terraform state list

# Output values
terraform output
terraform output instance_ip
````

---

## Variables and terraform.tfvars

### Define Variables

````hcl
# variables.tf
variable "environment" {
  type        = string
  description = "Environment (dev/prod)"
  default     = "dev"
}
````

### Provide Values

````bash
# terraform.tfvars
environment = "prod"
instance_type = "t2.small"

# or via command line
terraform apply -var="environment=prod"
````

---

## Multi-Environment Setup

````
dev.tfvars
├── instance_type = "t2.micro"
└── db_size = 20GB

prod.tfvars
├── instance_type = "t2.medium"
└── db_size = 100GB

# Deploy dev
terraform apply -var-file="dev.tfvars"

# Deploy prod
terraform apply -var-file="prod.tfvars"

# Same code, different configurations!
````

---

## Real Scenarios

### 3-Tier Architecture

````
VPC (10.0.0.0/16)
├── Public Subnets (Web tier)
│   ├── EC2 Instance (web servers)
│   └── Load Balancer
├── Private Subnets (App tier)
│   └── EC2 Instances (applications)
└── Database Subnets
    └── RDS PostgreSQL (database)

Everything defined in Terraform!
````

### Multi-Region Deployment

````hcl
# us-east-1
module "us_east" {
  source = "./modules/infrastructure"
  region = "us-east-1"
}

# eu-west-1
module "eu_west" {
  source = "./modules/infrastructure"
  region = "eu-west-1"
}

# Same infrastructure in 2 regions!
````

### Development vs Production

````bash
# Dev: cheap, small instances
terraform apply -var-file="dev.tfvars"

# Prod: expensive, large instances, redundant
terraform apply -var-file="prod.tfvars"

# Both from same Terraform code!
````

-


---

## Things That Clicked

- Terraform reads AWS credentials from ~/.aws/credentials
- main.tf defines resources
- variables.tf defines inputs
- outputs.tf defines what you want to see
- terraform plan shows what will change
- terraform apply makes it real
- terraform.tfstate tracks what was created
- Variables allow dev/prod from same code
- Git track Terraform files (not state!)

---

## Important Points

✅ **DO**:
- Commit main.tf, variables.tf, outputs.tf
- Use terraform.tfvars for defaults
- Review terraform plan before apply
- Destroy when testing is done
- Use variables for environments

❌ **DON'T**:
- Commit terraform.tfstate
- Commit terraform.tfvars (with real values)
- Edit .terraform directory
- Edit terraform.tfstate manually
- Change resource names (breaks state)

---



## Summary

Terraform is how DevOps teams manage infrastructure:

- **Code** — define infrastructure in text files
- **Reproducible** — same result every time
- **Versioned** — commit to Git, track changes
- **Automated** — one command creates everything
- **Multi-environment** — dev/prod from same code
- **AWS-focused** — all AWS resources supported

You now understand Infrastructure as Code. This directly supports your SAA certification goals. Tomorrow: Kubernetes (or ECS). 🚀

Today I built:
- VPC with 6 subnets
- EC2 web server
- RDS PostgreSQL database
- S3 bucket for files
- Security groups
- All as code

Version controlled.
Reproducible.
Automated.

This is how production systems are actually built.


#Terraform #IaC #AWS #DevOps #Week4
````
