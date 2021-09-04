terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}


resource "aws_vpc" "alpha-vpc" {
  cidr_block       = var.vpc-cidr-blocks
  instance_tenancy = "default"
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "subnet-module" {
  source                 = "./modules/subnet"
  vpc-id                 = aws_vpc.alpha-vpc.id
  subnet-cidr-block      = var.subnet-cidr-block
  avail_zone             = var.avail_zone
  env_prefix             = var.env_prefix
  default-route-table-id = aws_vpc.alpha-vpc.default_route_table_id

}

module "webserver-module" {
  source               = "./modules/webserver"
  vpc-id               = aws_vpc.alpha-vpc.id
  myip                 = var.myip
  env_prefix           = var.env_prefix
  instance-type        = var.instance-type
  key-name             = var.key-name
  avail_zone           = var.avail_zone
  private-key-location = var.private-key-location
  subnet-id            = module.subnet-module.subnet-id.id
}