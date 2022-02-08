variable "environment" {
    type = string
    description = "the environment type which will be tagged the resource e.g. dev. uat, stagging, prod"
    default = "dev"
}


variable "network_cidr" {
type=string
description="AWS network cidr"
}


variable "public_subnet_cidr" {
type=string
description="AWS public subnet cidr"
}

variable "private_subnet_cidr" {
type=string
description="AWS private subnet cidr"
}


variable "availability_zone_a" {
  type    = string
  default = "us-east-1a"
  description = "availability zone for subnet"
}

variable "availability_zone_b" {
  type    = string
  default = "us-east-1b"
  description = "availability zone for subnet"

}
