variable "create" {
  description = "Boolean to make module or not"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the deployment"
  type        = string
  default     = "polkadot-api"
}

variable "tags" {
  description = "Tags to associate with resources."
  type        = map(string)
  default     = {}
}

variable "node_purpose" {
  description = "What type of node are you deploying? (validator/library/truth)"
  type        = string
  default     = "library"

  //  validation {
  //    condition     = var.node_purpose == "validator" || var.node_purpose == "validator" || var.node_purpose == "truth"
  //    error_message = "The node_purpose value must be one of \"validator\", \"validator\", or \"truth\"."
  //  }
}

variable "subnet_id" {
  description = "The id of the subnet."
  type        = string
  default     = ""
}

variable "monitoring" {
  description = "Boolean for cloudwatch"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Root volume size"
  type        = string
  default     = 0
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "public_key" {
  description = "The public ssh key. key_name takes precidence"
  type        = string
  default     = ""
}

variable "private_key_path" {
  description = "Path to private key"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "The name of the preexisting key to be used instead of the local public_key_path"
  type        = string
  default     = ""
}

variable "storage_driver_type" {
  description = "Type of EBS storage the instance is using (nitro/standard)"
  type        = string
  default     = "standard"
}

variable "mount_volumes" {
  description = "Bool to enable non-root volume mounting"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "The ids of the security group to run in"
  type        = list(string)
  default     = []
}

module "user_data" {
  source         = "github.com/insight-infrastructure/terraform-polkadot-user-data.git?ref=master"
  type           = var.node_purpose
  cloud_provider = "aws"
  driver_type    = var.storage_driver_type
  mount_volumes  = var.mount_volumes
}

resource "aws_key_pair" "this" {
  count      = var.key_name == "" && var.create ? 1 : 0
  public_key = var.public_key
}

resource "aws_eip" "this" {
  count = var.create ? 1 : 0

  vpc = true

  lifecycle {
    prevent_destroy = false
  }

  tags = var.tags
}

resource "aws_eip_association" "this" {
  count = var.create ? 1 : 0

  allocation_id = aws_eip.this.*.id[count.index]
  instance_id   = join("", aws_instance.this.*.id)
}

resource "aws_instance" "this" {
  count = var.create ? 1 : 0

  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu.id
  user_data              = module.user_data.user_data
  subnet_id              = var.subnet_id
  vpc_security_group_ids = concat(var.security_group_ids, aws_security_group.this.*.id)
  monitoring             = var.monitoring
  key_name               = concat(aws_key_pair.this.*.key_name, [var.key_name])[0]
  iam_instance_profile   = var.iam_instance_profile == "" && local.create_source_of_truth ? join("", aws_iam_instance_profile.sot_host.*.name) : var.iam_instance_profile

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  tags = merge({ Name : var.name }, var.tags)
}

output "vpc_id" {
  value = var.vpc_id
}

output "subnet_id" {
  value = var.subnet_id
}

output "security_group_id" {
  value = var.security_group_ids
}

output "instance_id" {
  value = join("", aws_instance.this.*.id)
}

output "public_ip" {
  value = join("", aws_eip.this.*.public_ip)
}

output "private_ip" {
  value = join("", aws_instance.this.*.private_ip)
}

output "user_data" {
  value = join("", aws_instance.this.*.user_data)
}