variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "environment" {
  type        = string
  description = "Deployment environment name (eg. prod, dev)"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply"
  default     = {}
}

variable "availability_zones" {
  type        = list(string)
  description = "List of AZs to create subnets in"
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
}
