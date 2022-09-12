provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
}


variable "owner" {
  default = "dummy"
}