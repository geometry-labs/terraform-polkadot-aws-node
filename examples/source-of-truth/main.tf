variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

variable "public_key" {}
variable "private_key_path" {}

module "network" {
  source      = "github.com/geometry-labs/terraform-aws-polkadot-network.git?ref=main"
  api_enabled = true
  num_azs     = 1
}

module "default" {
  source             = "../.."
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