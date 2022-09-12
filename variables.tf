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
