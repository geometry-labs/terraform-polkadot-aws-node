variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

variable "public_key" {}
variable "private_key_path" {}

module "network" {
  source = "github.com/geometry-labs/terraform-polkadot-aws-network?ref=main"

  name        = "library-${random_pet.this.id}"
  api_enabled = true
  num_azs     = 1
}

resource "aws_security_group" "this" {
  description = "Example SG"
  vpc_id      = module.network.vpc_id
  name        = "example-sg"
}

resource "random_pet" "this" { length = 2 }

module "default" {
  source = "../.."

  name                  = "validator-${random_pet.this.id}"
  public_key            = var.public_key
  subnet_id             = module.network.public_subnets[0]
  security_group_ids    = [module.network.api_security_group_id]
  private_key_path      = var.private_key_path
  node_purpose          = "validator"
  create_security_group = false
  skip_health_check     = true

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

  depends_on = [module.network]
}

output "public_ip" {
  value = module.default.public_ip
}