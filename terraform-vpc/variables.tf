# Input variable definitions
variable "region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.55.0.0/16"
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "dummy-vpc-terraform"
}

variable "azs" {
  description = "Availability zones for VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  description = "Private subnets' cidr for VPC"
  type        = list(string)
  default     = ["10.55.1.0/24", "10.55.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnets' cidr for VPC"
  type        = list(string)
  default     = ["10.55.101.0/24", "10.55.102.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
  default     = true
}
















