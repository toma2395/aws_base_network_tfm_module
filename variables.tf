variable "environment" {
  type        = string
  description = "the environment type which will be tagged the resource e.g. dev. uat, stagging, prod"
  default     = "dev"
}

variable "owner" {
  type        = string
  description = "the owner of resources created"
  default     = "resource_owner_buddy"
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