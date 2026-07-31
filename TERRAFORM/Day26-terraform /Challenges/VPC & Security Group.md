# Terraform AWS Labs – VPC & Security Group

## Overview

This repository contains Terraform solutions for beginner AWS infrastructure provisioning tasks. These labs focus on understanding the fundamentals of Infrastructure as Code (IaC) by creating networking resources in AWS.

**Topics Covered**

* AWS Provider
* Terraform Resources
* Terraform Data Sources
* VPC Creation
* Security Groups
* IPv4 & IPv6 Networking
* Terraform Workflow (`init`, `fmt`, `validate`, `plan`, `apply`)

---

## Lab 1 – Create a Security Group

### Objective

Create a security group in the **default VPC** with the following configuration:

* **Name:** `datacenter-sg`
* **Description:** `Security group for Nautilus App Servers`
* **Inbound Rules:**

  * HTTP (TCP 80) from `0.0.0.0/0`
  * SSH (TCP 22) from `0.0.0.0/0`

### Concepts Learned

* AWS Provider
* Terraform Data Source (`aws_vpc`)
* Terraform Resource (`aws_security_group`)
* Ingress & Egress Rules
* Referencing existing AWS resources

---

## Lab 2 – Create a VPC (Custom IPv4 CIDR)

### Objective

Create a VPC with:

* **Name:** `datacenter-vpc`
* **Region:** `us-east-1`
* **CIDR Block:** `10.0.0.0/16` (or any valid IPv4 CIDR)

### Concepts Learned

* Creating AWS resources using Terraform
* Understanding VPCs
* IPv4 CIDR Blocks
* Resource Tags

---

## Lab 3 – Create a VPC (Specific IPv4 CIDR)

### Objective

Create a VPC with:

* **Name:** `nautilus-vpc`
* **CIDR Block:** `192.168.0.0/24`

### Concepts Learned

* Choosing appropriate CIDR blocks
* VPC naming through AWS tags
* Reusing Terraform resource patterns

---

## Lab 4 – Create a VPC with Amazon-Provided IPv6

### Objective

Create a VPC with:

* **Name:** `devops-vpc`
* Amazon-generated IPv6 CIDR block

### Important Learning

Although the task emphasized IPv6, a VPC still requires an IPv4 CIDR block.

```terraform
cidr_block = "10.0.0.0/16"
assign_generated_ipv6_cidr_block = true
```

### Error Encountered

```
InvalidParameterValue:
Value (None) for parameter cidrBlock is invalid.
```

### Root Cause

The VPC was created without an IPv4 CIDR block. AWS (and the LocalStack environment used in the lab) requires every VPC to have an IPv4 CIDR. The Amazon-provided IPv6 block is an additional address range, not a replacement.

---

## Terraform Workflow

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

### Command Purpose

| Command              | Description                                               |
| -------------------- | --------------------------------------------------------- |
| `terraform init`     | Downloads providers and initializes the working directory |
| `terraform fmt`      | Formats Terraform files                                   |
| `terraform validate` | Validates configuration syntax                            |
| `terraform plan`     | Shows planned infrastructure changes                      |
| `terraform apply`    | Creates or updates infrastructure                         |

---

## Key Terraform Concepts

### Provider

Defines which cloud provider Terraform will communicate with.

```terraform
provider "aws" {
  region = "us-east-1"
}
```

---

### Resource

Creates new infrastructure.

```terraform
resource "aws_vpc" "example" {

}
```

---

### Data Source

Reads existing infrastructure without creating it.

```terraform
data "aws_vpc" "default" {
  default = true
}
```

---

### Tags

Used to name and organize AWS resources.

```terraform
tags = {
  Name = "example-vpc"
}
```

---

## Networking Concepts

### IPv4

Example:

```
10.0.0.0/16
```

Private network used by AWS resources.

---

### IPv6

Enable an Amazon-generated IPv6 block:

```terraform
assign_generated_ipv6_cidr_block = true
```

---

## Repository Structure

```
terraform/
├── main.tf
├── provider.tf
└── README.md
```

---

## Key Takeaways

* Learned how Terraform communicates with AWS.
* Understood the difference between **Resources** and **Data Sources**.
* Created VPCs with both IPv4 and IPv6 networking.
* Configured Security Groups with HTTP and SSH access.
* Practiced the complete Terraform workflow.
* Troubleshot a VPC creation error related to missing IPv4 CIDR configuration.

---

## Learning Summary

These labs strengthened my understanding of AWS networking fundamentals and Infrastructure as Code using Terraform. They provided hands-on experience with provisioning VPCs, configuring Security Groups, and understanding how Terraform translates infrastructure definitions into real AWS resources.
