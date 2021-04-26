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
  source           = "../.."
  public_key       = var.public_key
  private_key_path = var.private_key_path
  node_purpose     = "library"
}

output "public_ip" {
  value = module.default.public_ip
}