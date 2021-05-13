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

locals {
  network_settings = {
    polkadot = {
      name                = "polkadot"
      shortname           = "polkadot"
      api_health          = "5000"
      polkadot_prometheus = "9610"
      json_rpc            = "9933"
      ws_rpc              = "9944"
    }
    kusama = {
      name                = "kusama"
      shortname           = "ksmcc3"
      api_health          = "5001"
      polkadot_prometheus = "9611"
      json_rpc            = "9934"
      ws_rpc              = "9945"
    }
  }
}

module "default" {
  source = "../.."

  name             = "default-${random_pet.this.id}"
  public_key       = var.public_key
  private_key_path = var.private_key_path
  node_purpose     = "library"
  network_settings = local.network_settings
}

output "public_ip" {
  value = module.default.public_ip
}