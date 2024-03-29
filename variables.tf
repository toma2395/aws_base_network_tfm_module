variable "aws_region" {
  default     = "us-east-1"
  description = "aws region for vpc deployment"
  type        = string
}

variable "environment" {
  type        = string
  description = "the environment type which will be tagged the resource e.g. dev. uat, stagging, prod"
  default     = "Development"
}

variable "owner" {
  type        = string
  description = "the owner of resources created"
  default     = "resource_owner_buddy"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enables DNS hostnames in VPC"
  default     = false
}

variable "project_name" {
  default     = ""
  type        = string
  description = "Project name used"
}

variable "cidr_range" {
  type        = string
  description = "AWS network cidr"
}

variable "create_nat_gateway" {
  default     = false
  description = "if true then create nat gateway for private subnets"
}

variable "create_internet_gateway" {
  default     = true
  description = "if true then create Internet Gateway for public subnets"
}

variable "multi_subnet_nat_gateway_for_vpc" {
  default     = false
  description = "if false then is only one NAT gateway for each subnets, if true the each prvate subnets has allocated NAT Gateway for itself"
}

variable "enable_vpc_flow_logs" {
  default     = false
  description = "if true enables vpc flow logs to generate and deliver"

}

variable "log_delivery_type" {
  default     = "cloud-watch-logs"
  description = "type of VPC flow logs delivery type"
}