provider "aws" {
  region     = local.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  region = "us-east-1"
}




variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "owner" {}