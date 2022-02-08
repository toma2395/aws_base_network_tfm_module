variable "environemnt" {
    type = string
    description = "the environment type which will be tagged the resource e.g. dev. uat, stagging, prod"
    default = "dev"
}


variable "network_cidr" {
type=string
desciption="AWS network cidr"
}


variable "public_subnet_cidr" {
type=string
desciption="AWS public subnet cidr"
}

variable "private_subnet_cidr" {
type=string
desciption="AWS private subnet cidr"
}


variable "availability_zone_a" {
  type    = string
  default = "us-east-1a"
}

variable "availability_zone_b" {
  type    = string
  default = "us-east-1b"
}
