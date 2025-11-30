variable "cidr_block" {
    description = "CIDR block for the VPC"
    type        = string
}

variable "public_subnet_cidrs" {
    description = "CIDR blocks for public subnets"
    type        = list(string)
}

variable "private_subnet_cidrs" {
    description = "CIDR blocks for private subnets"
    type        = list(string)
}

variable "availability_zones" {
    description = "Availability zones for subnets"
    type        = list(string)
}

variable "environment" {
    description = "Environment name"
    type        = string
}

variable "tags" {
    description = "Common tags to apply to all resources"
    type        = map(string)
    default     = {}
}