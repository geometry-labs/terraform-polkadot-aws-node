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
  consul_enabled        = false
  hardening_enabled     = true
  mount_volumes         = false

  depends_on = [module.network]
}

output "public_ip" {
  value = module.default.public_ip
}