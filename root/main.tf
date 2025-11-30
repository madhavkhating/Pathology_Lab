// Top-level Terraform file to execute modules

variable "environment" {
  type    = string
  default = "prod"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "common_tags" {
  type    = map(string)
  default = { Owner = "pathology" }
}

module "aws_network" {
  source               = "./modules/aws_network"
  cidr_block           = var.cidr_block
  environment          = var.environment
  tags                 = var.common_tags
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

// Placeholder calls for other modules (implementations not present yet)
// module "security_group" {
//   source = "./modules/security_group"
// }

// module "lamp_asg" {
//   source = "./modules/lamp_asg"
// }

// module "rds_mysql" {
//   source = "./modules/rds_mysql"
// }

// module "s3_backup" {
//   source = "./modules/s3_backup"
// }

output "vpc_id" {
  value       = module.aws_network.vpc_id
  description = "VPC ID from aws_network module"
}

output "public_subnets" {
  value       = module.aws_network.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnets" {
  value       = module.aws_network.private_subnet_ids
  description = "Private subnet IDs"
}
