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
  name           = random_pet.this.id
  cidr           = "10.0.0.0/24"
  azs            = ["${var.aws_region}a"]
  public_subnets = ["10.0.0.0/24"]
  tags = {
    Environment = "CI"
  }
}

module "default" {
  source           = "../.."
  public_key       = var.public_key
  subnet_id        = module.vpc.public_subnets[0]
  vpc_id           = module.vpc.vpc_id
  private_key_path = var.private_key_path
  node_purpose     = "library"
  skip_health_check = true
}

output "public_ip" {
  value = module.default.public_ip
}