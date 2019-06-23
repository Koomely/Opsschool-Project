#################################################
# VARIABLES
#################################################

### General Vars

variable "aws_access_key" {}
variable "aws_secret_key" {}
/*
variable "private_key_path" {}
variable "key_name" {}
*/
variable "region_name" {
    default = "us-east-1"
}

### Provider\VPC Vars

variable "cidr" {
    default = "10.0.0.0/16"  
}

variable "count" {
    default = 1
}

