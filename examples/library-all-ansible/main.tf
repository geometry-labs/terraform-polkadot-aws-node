variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

variable "public_key" {}
variable "private_key_path" {}

resource "random_pet" "this" {
  length = 2
}

module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  name           = "library-${random_pet.this.id}"
  cidr           = "10.0.0.0/24"
  azs            = ["${var.aws_region}a"]
  public_subnets = ["10.0.0.0/24"]
  tags = {
    Environment = "CI"
  }
}

resource "aws_security_group" "this" {
  description = "Example SG"
  vpc_id      = module.vpc.vpc_id
  name        = "example-sg"
}

module "default" {
  source = "../.."

  name             = "library-${random_pet.this.id}"
  public_key       = var.public_key
  subnet_id        = module.vpc.public_subnets[0]
  vpc_id           = module.vpc.vpc_id
  private_key_path = var.private_key_path
  node_purpose     = "library"

  consul_enabled              = true
  consul_gossip_key           = "BXs1MAyl+tTUIKEFZCzivhmY9a0dCUxXdgRZyzPJ6QA="
  consul_auto_encrypt_enabled = true
  consul_connect_enabled      = true
  consul_acl_enable           = true
  consul_acl_datacenter       = "dc1"
  consul_acl_token            = "00000000-0000-0000-0000-000000000002"
  prometheus_enabled          = true
  cluster_name                = "example"
  consul_security_group       = aws_security_group.this.id

  depends_on = [module.vpc] # Needed due to vpc data sources
}

output "public_ip" {
  value = module.default.public_ip
}