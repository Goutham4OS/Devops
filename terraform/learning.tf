// Terraform learning file: core blocks, meta-arguments, and patterns.
// This file is intentionally verbose and comment-heavy so you can learn by example.
// NOTE: Some blocks are commented out or use placeholder values to avoid real changes.

terraform {
  // The terraform block configures settings for the CLI and backends.
  // backend "s3" is commented to avoid accidental state changes.
  // required_version ensures consistent CLI behavior.
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  // backend "s3" {
  //   bucket         = "my-tf-state"
  //   key            = "envs/dev/terraform.tfstate"
  //   region         = "us-east-1"
  //   dynamodb_table = "my-tf-locks" // state locking
  //   encrypt        = true
  // }
}

provider "aws" {
  // Provider config uses variables and locals for flexibility.
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

// VARIABLES -----------------------------------------------------------------
// Input variables let you parameterize your configuration.
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\d$", var.aws_region))
    error_message = "Region must look like us-east-1."
  }
}

variable "environment" {
  description = "Deployment environment (dev/stage/prod)"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "instance_count must be between 1 and 10."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for instances"
  type        = list(string)
}

// LOCALS ---------------------------------------------------------------------
// Locals are computed values used to DRY up your config.
locals {
  name_prefix = "${var.environment}-web"
  common_tags = {
    project     = "learning"
    environment = var.environment
    managed_by  = "terraform"
  }
}

// DATA SOURCES ---------------------------------------------------------------
// Data sources read existing infrastructure.
// Example: find latest Amazon Linux 2 AMI.
data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

// RESOURCES ------------------------------------------------------------------
// Resources create or manage infrastructure.
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-sg"
  description = "Allow HTTP/HTTPS"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_instance" "web" {
  // Meta-arguments:
  // count -> creates N copies
  count = var.instance_count

  // for_each is an alternative when you want stable keys
  // for_each = toset(var.subnet_ids)

  ami           = data.aws_ami.amzn2.id
  instance_type = "t3.micro"

  // Example for count: distribute across subnets by index
  subnet_id = var.subnet_ids[count.index % length(var.subnet_ids)]

  vpc_security_group_ids = [aws_security_group.web.id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${count.index + 1}"
  })

  // lifecycle meta-argument controls changes.
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [tags["LastUpdated"]]
  }

  // depends_on explicitly orders resources when needed.
  depends_on = [aws_security_group.web]
}

// NULL RESOURCE --------------------------------------------------------------
// null_resource can run provisioners or trigger actions.
// Use sparingly; prefer native resources or external pipelines.
resource "null_resource" "notify" {
  triggers = {
    instance_ids = join(",", aws_instance.web[*].id)
  }

  // local-exec provisioner example
  provisioner "local-exec" {
    command = "echo Instances changed: ${self.triggers.instance_ids}"
  }
}

// MODULES --------------------------------------------------------------------
// Modules are reusable bundles of Terraform config.
// Example of calling a module (commented to avoid external dependency).
// module "vpc" {
//   source  = "terraform-aws-modules/vpc/aws"
//   version = "5.1.0"
//   name    = "${local.name_prefix}-vpc"
//   cidr    = "10.0.0.0/16"
// }

// OUTPUTS --------------------------------------------------------------------
// Outputs expose values after apply for other modules or users.
output "instance_ids" {
  description = "IDs of the created instances"
  value       = aws_instance.web[*].id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web.id
}

// META-ARGUMENTS (summary)
// - depends_on: explicit dependency
// - count: create N instances, indexed by count.index
// - for_each: create per map/set with stable keys
// - lifecycle: customize create/replace/destroy behavior
// - provider: override provider config per resource (alias)

// QUICK MEMORY AID
// Inputs -> Logic -> Outputs
// Variables -> Locals/Data/Resources/Modules -> Outputs
// State is the "memory" that connects this config to real infrastructure.
