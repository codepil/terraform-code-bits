# Submodule: generate-subnets  
This module's purpose is to generate the opinionated subnetting and secondary VPC configurations as part of the GCP LZ project.

While it is parameterized for flexibility, it may not be suitable for general purpose subnet mapping creation without a little more polish.  
Specifically, it is designed to be used with https://github.com/terraform-google-modules/terraform-google-network.

NOTE:  If you wish to use https://github.com/terraform-google-modules/cloud-foundation-fabric instead, it will require modification as that module requires parameters of different structures.

## Requirements

No requirements.

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Lifecycle of the subnets being generated. Whatever is passed will be injected in to the subnet name as it's lifecycle | `string` | n/a | yes |
| region\_cidrs | Map of regional CIDRs in which to create subnets. Should map 1:1 with regions variable.  ie: {us-east1="100.112.0.0/17",us-central1="100.112.128.0/17"} | `map(string)` | n/a | yes |
| region\_secondary\_cidrs | Map of regional CIDRs in which to create the secondary ranges.  Map keys should be same or subset of the subnet\_regions. | `map(string)` | `{}` | no |
| secondary\_map\_fields | Map of keys used in each secondary range map.  Only needs changing if you need to change the key names in the output. | `map(string)` | <pre>{<br>  "cidr_key": "ip_cidr_range",<br>  "name_key": "range_name"<br>}</pre> | no |
| secondary\_offsets | Map of secondary range offsets and masks to be used in conjunction with region\_secondary\_cidrs to calculate regional subnet secondary range CIDRS and secondary names.  If not provided, a default mapping based on best practices will be used instead.   Should be a map of subnet name suffixes pointing to map of secondary range name suffices, pointing to map of strings containing 'offset' and 'mask' keys | `map(map(map(string)))` | `{}` | no |
| subnet\_attributes | Map of additional attributes to merge into all subnets | `map(string)` | <pre>{<br>  "subnet_flow_logs": "true",<br>  "subnet_flow_logs_interval": "INTERVAL_5_MIN",<br>  "subnet_flow_logs_sampling": 0.5<br>}</pre> | no |
| subnet\_map\_fields | Map of keys used in each subnet map.  Only needs changing if you need to change the key names in the output. | `map(string)` | <pre>{<br>  "cidr_key": "subnet_ip",<br>  "name_key": "subnet_name",<br>  "region_key": "subnet_region"<br>}</pre> | no |
| subnet\_offsets | Map of subnet offsets and masks to be used against region\_cidrs to calculate regional subnet CIDRS. If not provided, a default mapping based on best practices will be used instead.  Should be a map of subnet name suffixes pointing to map of strings containing 'offset' and 'mask' keys. | `map(map(string))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| secondary\_ranges | Map of subnet secondary ranges with key being the subnet name, each pointing to list of objects, those objects being a map of strings using keys range\_name and ip\_cidr\_range. |
| subnets | Map of subnets, with key being the subnet name and the value being a map of strings using keys subnet\_ip, subnet\_name, and subnet\_region. |

