# modules/vpc/variables.tf

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "devopswithpankaj-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.77.0.0/16"
}

variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.77.101.0/24", "10.77.102.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.77.1.0/24", "10.77.2.0/24"]
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway for private subnets outbound internet"
  type        = bool
  default     = true
}
