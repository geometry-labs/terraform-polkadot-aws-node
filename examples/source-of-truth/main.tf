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
  source               = "../.."
  name                 = "library-${random_pet.this.id}"
  public_key           = var.public_key
  subnet_id            = module.network.public_subnets[0]
  vpc_id               = module.network.vpc_id
  security_group_ids   = [module.network.api_security_group_id]
  private_key_path     = var.private_key_path
  node_purpose         = "truth"
  mount_volumes        = false
  skip_health_check    = true
  polkadot_client_url  = "https://github.com/paritytech/polkadot/releases/download/v0.9.12/polkadot"
  polkadot_client_hash = "4a06a043e8fec42e09384a7ebab4331d138101ee55846af356e08d38982d767a"

  depends_on = [module.network]
}

output "public_ip" {
  value = module.default.public_ip
}