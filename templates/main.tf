variable "aws_region" {
  default = "us-east-2"
}

provider "aws" {
  region = var.aws_region
}

variable "public_key" {}
variable "private_key_path" {}

resource "random_pet" "this" {
  length = 2
}

module "default" {
#  source = "github.com/geometry-labs/terraform-polkadot-aws-node.git?ref={{module_version}}"
  source = "../.."
  name                 = "default-${random_pet.this.id}"
  public_key           = var.public_key
  private_key_path     = var.private_key_path
  node_purpose         = "{{node_purpose}}"
#  polkadot_client_url  = "https://github.com/paritytech/polkadot/releases/download/v0.9.12/polkadot"
#  polkadot_client_hash = "4a06a043e8fec42e09384a7ebab4331d138101ee55846af356e08d38982d767a"

  polkadot_client_url = "{{polkadot_client_url}}"
  skip_health_check     = {{skip_health_check|lower}}
  consul_enabled        = {{consul_enabled|lower}}
  hardening_enabled     = {{hardening_enabled|lower}}
  mount_volumes         = {{mount_volumes|lower}}
}

output "public_ip" {
  value = module.default.public_ip
}