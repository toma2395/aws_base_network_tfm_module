# aws-terraform-networking-module

This module builds a well architected VPC network with varying options.  

## Basic Usage

```HCL
module "network" {
  source = "git@github.com:toma2395/aws_base_network_tfm_module.git//?ref=v1.0.0"

  environment                      = "production"
  cidr_range                       = "172.30.0.0/16"
  owner                            = var.owner
  project_name                     = "MySampleProject"
  create_nat_gateway               = true
  multi_subnet_nat_gateway_for_vpc = false
}
```

Full working references are available at [examples](examples)

## Terraform 0.12 upgrade

Several changes were required while adding terraform 0.12 compatibility.  The following changes should be  
made when upgrading from a previous release to version 0.12.0 or higher.

### Module variables


## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 3.74.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.74.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/3.74.0/docs/resources/s3_bucket) |
| and many others |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region for vpc deployment | `string` | `us-east-1` | no |
| environment | Application environment for which this network is being created. must be one of ['Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test'] | `string` | `"Development"` | yes |
| cidr_range | AWS network cidr | `string` |  | yes |
| owner | the owner of resources created | `string` |  | no |
| project_name | Project name used | `string` |  | no |
| create_nat_gateway | Project name used | `bool` |  `false` | no |
| create_internet_gateway | Project name used | `bool` |  `false` | no |
| multi_subnet_nat_gateway_for_vpc | Project name used | `bool`|  `false` | no |
| enable_vpc_flow_logs | Project name used | `bool` | `false` | no |
| log_delivery_type | type of VPC flow logs delivery type -> one of ["cloud-watch-logs", "s3"]| `string` | `cloud-watch-logs` | no |
| enable_dns_hostnames | Enables DNS hostnames in VPC | `bool` | `false` | no |



## Outputs

| Name | Description |
|------|-------------|
| core\_vpc\_id | vpc id of created network |
| private\_subnets\_ips | IPs for the private subnets in a list of tuple format |
| public\_subnets\_ips | IPs for the public subnets in a list of tuple format |
| private\_subnets\_id | Identifiers of private subnets in a list of tuple format |
| public\_subnets\_id | Identifiers of public subnets in a list of tuple format |
| bucket\_website\_domain | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. |
| bucket\_website\_endpoint | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |