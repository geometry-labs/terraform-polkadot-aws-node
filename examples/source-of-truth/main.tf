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

resource "random_pet" "this" {
  length = 2
}

module "default" {
  source             = "../.."
  name               = "library-${random_pet.this.id}"
  public_key         = var.public_key
  subnet_id          = module.network.public_subnets[0]
  vpc_id             = module.network.vpc_id
  security_group_ids = [module.network.api_security_group_id]
  private_key_path   = var.private_key_path
  node_purpose       = "truth"

  depends_on = [module.network]
}

output "public_ip" {
  value = module.default.public_ip
}